#include <assert.h>
#include <limits.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

/* Optimized level generation routines.  */



/* Aquifer routines.  */

static void
unhash (unsigned int hash, int *lx, int *ly, int *lz)
{
#ifndef __GNUC__
  *lx = ((hash & 0x3ff)
	 | ((0 - ((hash & 0x200) >> 9)) & ~0x3ff));
  *ly = (((hash >> 10) & 0x3ff)
	 | ((0 - ((hash & 0x80000) >> 19)) & ~0x3ff));
  *lz = (((hash >> 20) & 0x3ff)
	 | ((0 - ((hash & 0x20000000) >> 29)) & ~0x3ff));
#else /* __GNUC__ */
  *lx = (int) (hash << 22) >> 22;
  *ly = (int) (hash << 12) >> 22;
  *lz = (int) (hash << 2) >> 22;
#endif /* __GNUC__ */
}

#define dist_closest 1
#define dist_average 2
#define dist_furthest 3
#define pos_closest 4
#define pos_average 5
#define pos_furthest 6

static void
fix_distances (int *distbuf, int pos, int dx, int dy, int dz)
{
  int d = dx * dx + dy * dy + dz * dz;

  if (distbuf[dist_closest] >= d)
    {
      distbuf[pos_furthest] = distbuf[pos_average];
      distbuf[dist_furthest] = distbuf[dist_average];
      distbuf[pos_average] = distbuf[pos_closest];
      distbuf[dist_average] = distbuf[dist_closest];
      distbuf[pos_closest] = pos;
      distbuf[dist_closest] = d;
    }
  else if (distbuf[dist_average] >= d)
    {
      distbuf[pos_furthest] = distbuf[pos_average];
      distbuf[dist_furthest] = distbuf[dist_average];
      distbuf[pos_average] = pos;
      distbuf[dist_average] = d;
    }
  else if (distbuf[dist_furthest] >= d)
    {
      distbuf[pos_furthest] = pos;
      distbuf[dist_furthest] = d;
    }
}

void
pick_grid_positions_1 (int *distbuf, int rx, int ry, int rz)
{
  int i;

  for (i = 7; i <= 18; ++i)
    {
      int hash = (int) distbuf[i];
      int lx, ly, lz;

      unhash (hash, &lx, &ly, &lz);
      fix_distances (distbuf, hash, lx - rx, ly - ry, lz - rz);
    }
}



/* Biome indexing routines.  */

#define max(a, b) ((a) > (b) ? (a) : (b))

static long long
distance_to_value_sqr (int range, int value)
{
  int dmax = value - (range & 0xffff) + 32768;
#ifndef __GNUC__
  int dmin = (((range >> 16) & 0xffff)
	      | ((0 - ((range & 0x800000000) >> 31)) & 0xffff0000)) - value;
#else /* __GNUC__ */
  int dmin = (range >> 16) - value;
#endif /* __GNUC__ */  
  long long m;

  /* For consistency with Minecraft, this comparison function treats
     the upper bounds of these ranges as inclusive values.  */
  m = dmax > 0 ? dmax : max (dmin, 0);
  return m * m;
}

static long long
distance_total (int extents[restrict 7], int coords[restrict 7])
{
  long long d = 0, i;

  for (i = 0; i < 7; ++i)
    d += distance_to_value_sqr (extents[i], coords[i]);
  return d;
}

#define M 6

struct NoiseNode
{
  /* This node's children, if not a leaf node.  Undefined
     otherwise.  */
  struct NoiseNode *children[M];

  /* ID of the biome if a leaf node, or -1 otherwise.  */
  int noise_biome;

  /* Extents of the hypercube enclosing this node in the packed format
     accepted by distance_to_value_sqr.  */
  int extents[7];
};

typedef struct NoiseNode NoiseNode;

struct NoiseSamplerRTree
{
  /* Node previously encountered, which is always tested first to
     optimize closely adjacent biome samples.  */
  NoiseNode *last_result;

  /* Root of the tree.  */
  NoiseNode *root;
};

typedef struct NoiseSamplerRTree NoiseSamplerRTree;

static NoiseNode *
rtree_index_1 (NoiseNode *root, NoiseNode **leaf_out, int coords[7],
	       long long *distance_out)
{
  int i;
  long long distance = *distance_out;
  NoiseNode *leaf = *leaf_out;

  for (i = 0; i < M && root->children[i]; ++i)
    {
      NoiseNode *n = root->children[i];
      /* d must be less than distance if it contains any constituents
	 of which the same holds true.  */
      long long d = distance_total (n->extents, coords);

      if (d < distance && n->noise_biome != -1)
	{
	  leaf = n;
	  distance = d;
	}
      else if (d < distance)
	rtree_index_1 (n, &leaf, coords, &distance);
    }
  *leaf_out = leaf;
  *distance_out = distance;
  return leaf;
}

int
rtree_index_closest (NoiseSamplerRTree *rtree, int coords[7])
{
  NoiseNode *leaf = rtree->last_result;
  long long distance
    = (leaf ? distance_total (leaf->extents, coords) : LLONG_MAX);
  leaf = rtree_index_1 (rtree->root, &leaf, coords, &distance);
  rtree->last_result = leaf;
  return leaf->noise_biome;
}

static NoiseNode *
copy_node_recursively (NoiseNode *root, NoiseNode **storage)
{
  NoiseNode *node = (*storage)++;
  int i;

  if (!node)
    abort ();

  memset (node, 0, sizeof *node);
  if (root->noise_biome == -1)
    {
      for (i = 0; i < M && root->children[i]; ++i)
	node->children[i]
	  = copy_node_recursively (root->children[i], storage);
    }
  node->noise_biome = root->noise_biome;
  memcpy (node->extents, root->extents, sizeof node->extents);
  return node;
}

static int
count_nodes (NoiseNode *node)
{
  int i, nodes = 1;

  for (i = 0; i < M && node->children[i]; ++i)
    nodes += count_nodes (node->children[i]);
  return nodes;
}

NoiseSamplerRTree *
build_rtree (NoiseNode *root)
{
  NoiseSamplerRTree *tree = malloc (sizeof *tree);
  NoiseNode *storage;
  int n;

  if (!tree)
    abort ();

  n = count_nodes (root);
  tree->last_result = NULL;
  storage = calloc (n, sizeof *tree->root);
  if (!storage)
    abort ();
  tree->root = copy_node_recursively (root, &storage);
  assert (storage == tree->root + n);
  return tree;
}

void
free_rtree (NoiseSamplerRTree *rtree)
{
  free (rtree->root);
  free (rtree);
}
