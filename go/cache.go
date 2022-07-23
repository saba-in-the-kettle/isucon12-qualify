package isuports

import (
	"sync"
	"time"

	"github.com/patrickmn/go-cache"
)

// Cache は Type Parameterに対応したKey Value Storeです
type Cache[V any] struct {
	cache *cache.Cache
}

func NewCache[V any]() *Cache[V] {
	return &Cache[V]{cache: cache.New(cache.NoExpiration, cache.NoExpiration)}
}
func NewCacheWithExpire[K comparable, V any](defaultExpiration, cleanupInterval time.Duration) *Cache[V] {
	return &Cache[V]{cache: cache.New(defaultExpiration, cleanupInterval)}
}

func (c *Cache[V]) Get(key string) (V, bool) {
	v, ok := c.cache.Get(key)
	if ok {
		return v.(V), true
	}
	var defaultValue V
	return defaultValue, false
}

func (c *Cache[V]) Set(k string, v V) {
	c.cache.Set(k, v, cache.DefaultExpiration)
}

func (c *Cache[V]) SetWithExpire(k string, v V, d time.Duration) {
	c.cache.Set(k, v, d)
}

// Flush はキャッシュをクリアします
func (c *Cache[V]) Flush() {
	c.cache.Flush()
}

// SliceCache は []V をキャッシュする構造体です
type SliceCache[K comparable, V any] struct {
	item map[K][]V
	sync.RWMutex
}

func NewSliceCache[K comparable, V any]() *SliceCache[K, V] {
	return &SliceCache[K, V]{
		item:    map[K][]V{},
		RWMutex: sync.RWMutex{},
	}
}

func (sc *SliceCache[K, V]) Get(key K) []V {
	sc.RLock()
	defer sc.RUnlock()

	return sc.item[key]
}

func (sc *SliceCache[K, V]) Append(key K, value V) {
	sc.Lock()
	defer sc.Unlock()

	if len(sc.item[key]) == 0 {
		sc.item[key] = []V{}
	}

	sc.item[key] = append(sc.item[key], value)
}
