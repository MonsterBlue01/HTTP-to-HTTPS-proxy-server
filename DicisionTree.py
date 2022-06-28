from math import log

def uniquecounts(rows):
    results = {}
    for row in rows:
        r = row[len(row)-1]
        if r not in results:
            results[r] = 0
        results[r] += 1
    return results

def entropy(rows):
    log2 = lambda x:log(x)/log(2)
    results = uniquecounts(rows)
    ent = 0.0
    for r in results.keys():
        p = float(results[r])/len(rows)
        ent = ent - p*log2(p)
    return ent

# https://zhuanlan.zhihu.com/p/20794583