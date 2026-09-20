#ifndef CHOWDREN_HUFFMAN_H
#define CHOWDREN_HUFFMAN_H

#include "platform.h"
#include "datastream.h"
#include <stdlib.h>

class HuffmanNode
{
public:
    int frequency;
    unsigned char value;
    unsigned int dw_code;
    int code_length;
    HuffmanNode *parent, *left, *right;

    HuffmanNode()
    : frequency(0), value(0), dw_code(0), code_length(0), parent(NULL),
      left(NULL), right(NULL)
    {
    }
};

int frequency_compare(const void * elem1, const void * elem2)
{
    HuffmanNode * a = (HuffmanNode*)elem1;
    HuffmanNode * b = (HuffmanNode*)elem2;
    if(a->frequency == b->frequency)
        return 0;
    return a->frequency < b->frequency ? 1 : -1;
}

int char_value_compare(const void * elem1, const void * elem2)
{
    HuffmanNode * a = (HuffmanNode*)elem1;
    HuffmanNode * b = (HuffmanNode*)elem2;
    return a->value > b->value ? 1 : -1;
}

HuffmanNode* pop_node(HuffmanNode * nodes[], int index, bool right)
{
    HuffmanNode * node = nodes[index];
    node->dw_code = right;
    node->code_length = 1;
    return node;
}

void set_node_code(HuffmanNode* node)
{
    HuffmanNode * parent = node->parent;

    while (parent && parent->code_length) {
        node->dw_code <<= 1;
        node->dw_code |= parent->dw_code;
        node->code_length++;
        parent = parent->parent;
    }
}

int get_huffman_tree(HuffmanNode in_nodes[], bool set_codes = true)
{
    HuffmanNode * nodes[256];
    HuffmanNode * node;

    // add used ascii to Huffman queue
    int node_count = 0;
    for(int i = 0; i < 256 && in_nodes[i].frequency; i++)
        nodes[node_count++] = &in_nodes[i];
    int parent_node = node_count;
    int back_node = node_count-1;

    while (back_node > 0) {
        // parent node
        node = &in_nodes[parent_node++];
        // pop first child
        node->left = pop_node(nodes, back_node--, false);
        // pop second child
        node->right = pop_node(nodes, back_node--, true);
        // adjust parent of the two poped nodes
        node->left->parent = node->right->parent = node;
        // adjust parent frequency
        node->frequency = node->left->frequency + node->right->frequency;
        // insert parent node depending on its frequency

        int start_node;
        for(start_node = back_node; start_node >= 0; start_node--)
            if(nodes[start_node]->frequency >= node->frequency)
                break;

        for (int n = back_node - 1; n >= start_node; n--)
            nodes[n+2] = nodes[n+1];

        // for (int n = back_node - start_node - 1; n >= 0; n--)
        //     nodes[start_node + n + 2] = nodes[start_node + n + 1];

        nodes[start_node+1] = node;
        back_node++;
    }

    // set tree leaves nodes code
    if (set_codes)
        for(int i = 0; i < node_count; i++)
            set_node_code(&in_nodes[i]);

    return node_count;
}

#define HUFFMAN_MAGIC 0xE482B83C

bool compress_huffman(const std::string & in_data, const char * filename)
{
    FSFile fp(filename, "w");
    if (!fp.is_open()) {
        std::cout << "Could not open Huffman file " << filename << std::endl;
        return false;
    }
    FileStream stream(fp);

    HuffmanNode nodes[511];

    // initialize nodes ascii
    for(int i = 0; i < 256; i++)
        nodes[i].value = i;

    // get ascii frequencies
    for(unsigned int i = 0; i < in_data.size(); i++)
        nodes[(unsigned char)in_data[i]].frequency++;

    // sort ascii chars depending on frequency
    qsort(nodes, 256, sizeof(HuffmanNode), frequency_compare);

    // construct Huffman tree
    int node_count = get_huffman_tree(nodes);

    // construct compressed buffer
    stream.write_uint32(HUFFMAN_MAGIC);
    stream.write_uint32(in_data.size());
    stream.write_uint8(node_count-1);

    // save Huffman tree used leaves nodes
    for(int i = 0; i < node_count; i++) {
        stream.write_int32(nodes[i].frequency);
        stream.write_uint8(nodes[i].value);
    }

    // sort nodes depending on ascii to can index nodes with its ascii value
    qsort(nodes, 256, sizeof(HuffmanNode), char_value_compare);

    unsigned char code = 0;
    int bit_index = 0;
    // loop to write codes
    for (unsigned int i = 0; i < in_data.size(); i++) {
        HuffmanNode & node = nodes[(unsigned char)in_data[i]];
        int append_code = node.dw_code;

        for (int ii = 0; ii < node.code_length; ii++) {
            code |= (append_code & 1) << bit_index;
            append_code >>= 1;
            bit_index++;

            if (bit_index >= 8) {
                bit_index -= 8;
                stream.write_uint8(code);
                code = 0;
            }
        }
    }
    return true;
}

bool decompress_huffman(const char * filename, std::string & out)
{
    FSFile fp(filename, "r");
    if (!fp.is_open()) {
        std::cout << "Could not open Huffman file " << filename << std::endl;
        return false;
    }
    FileStream stream(fp);

    if (stream.read_uint32() != HUFFMAN_MAGIC)
        return false;

    out.resize(stream.read_uint32());

    int node_count = int(stream.read_uint8()) + 1;

    // initialize Huffman nodes with frequency and ascii
    HuffmanNode nodes[511];

    for (int i = 0; i < node_count; i++) {
        nodes[i].frequency = stream.read_int32();
        nodes[i].value = stream.read_uint8();
    }

    // construct Huffman tree
    get_huffman_tree(nodes, false);

    // get huffman tree root
    HuffmanNode * root = &nodes[0];
    while (root->parent)
        root = root->parent;

    unsigned int dst_index = 0;
    int bit_index = 0;
    unsigned char code = stream.read_uint8();

    HuffmanNode * node;
    while (dst_index < out.size()) {
        node = root;
        // if node has left then it must has right
        while (node->left) {
            // node not leaf
            node = (code&1) ? node->right : node->left;
            code >>= 1;
            bit_index++;
            if (bit_index >= 8) {
                bit_index -= 8;
                code = stream.read_uint8();
            }
        }
        out[dst_index++] = node->value;
    }

    return true;
}

#endif // CHOWDREN_HUFFMAN_H
