using System;
using System.Collections;
using EntityComponent;
using JumpKing;
using JumpKing.GogGalaxy;
using JumpKing.MiscSystems.Achievements;
using MonoMod;

namespace JumpKingPatches
{
    [MonoModPatch("global::EntityComponent.EntityManager")]
    internal class patch_EntityManager : EntityManager
    {
        private Hashtable __findCache;
        private object __findMiss;

        private void ClearFindCache()
        {
            if (__findCache != null)
                __findCache.Clear();
        }

        [MonoModReplace]
        public T Find<T>()
        {
            Type type = typeof(T);
            if (__findCache == null)
            {
                __findCache = new Hashtable();
                __findMiss = new object();
            }

            if (__findCache.ContainsKey(type))
            {
                object cached = __findCache[type];
                if (cached == __findMiss)
                    return default(T);
                return (T)cached;
            }

            var entities = Entities;
            for (int i = 0; i < entities.Count; i++)
            {
                object entity = entities[i];
                if (entity.GetType() == type)
                {
                    __findCache[type] = entity;
                    return (T)entity;
                }
            }

            __findCache[type] = __findMiss;
            return default(T);
        }

        public void AddObject(Entity entity)
        {
            ClearFindCache();
            orig_AddObject(entity);
        }

        public void orig_AddObject(Entity entity)
        {
        }

        public void DestroyAll()
        {
            ClearFindCache();
            orig_DestroyAll();
        }

        public void orig_DestroyAll()
        {
        }

        public void PlaceAtFront(Entity entity)
        {
            ClearFindCache();
            orig_PlaceAtFront(entity);
        }

        public void orig_PlaceAtFront(Entity entity)
        {
        }

        public void RemoveObject(Entity entity)
        {
            ClearFindCache();
            orig_RemoveObject(entity);
        }

        public void orig_RemoveObject(Entity entity)
        {
        }
    }

    [MonoModPatch("global::JumpKing.AmbienceManager")]
    internal class patch_AmbienceManager : AmbienceManager
    {
        private static int __loadTick;

        public void LoadSounds()
        {
            __loadTick++;
            if (__loadTick <= 1 || (__loadTick % 30) == 0)
                orig_LoadSounds();
        }

        public void orig_LoadSounds()
        {
        }
    }

    [MonoModPatch("global::JumpKing.GogGalaxy.GalaxyManager")]
    internal class patch_GalaxyManager : GalaxyManager
    {
        [MonoModReplace]
        public static void Initialize()
        {
        }

        [MonoModReplace]
        public void Update()
        {
        }

        [MonoModReplace]
        public void Init()
        {
        }

        [MonoModReplace]
        public void ListenersInit()
        {
        }

        [MonoModReplace]
        public void SignIn()
        {
        }

        [MonoModReplace]
        public new virtual void Dispose()
        {
        }
    }

    [MonoModPatch("global::JumpKing.GogGalaxy.GalaxyManager/AuthenticationListener")]
    internal class patch_AuthenticationListener
    {
        [MonoModReplace]
        public virtual void OnAuthSuccess()
        {
        }
    }

    [MonoModPatch("global::JumpKing.GogGalaxy.StatsAndAchievements")]
    internal class patch_StatsAndAchievements : StatsAndAchievements
    {
        [MonoModReplace]
        public void RequestUserStatsAndAchievements()
        {
        }
    }

    [MonoModPatch("global::JumpKing.MiscSystems.Achievements.AchievementRegister")]
    internal class patch_AchievementRegister
    {
        [MonoModReplace]
        public static void RegisterAchievement(AchievementCode code)
        {
        }

        [MonoModReplace]
        public static void CLEAR_ACHIEVEMENT_DEBUG()
        {
        }
    }
}
