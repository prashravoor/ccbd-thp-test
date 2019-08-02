lines = []
with open('/proc/buddyinfo') as f:
    lines = f.readlines()
    f.close()


blocks = {}
for line in lines:
    tmp = list(map(lambda x: x.strip(), line.split()))[3:]
    bl = list(map(lambda x: int(x), tmp[1:]))
    blocks[tmp[0]] = bl

alloc_index = 9 # 2^9 * 4KB = 2MB

for name in blocks:
    block = blocks[name]
    max_alloc_index = len(block)
    total_pages = 0
    for i in range(len(block)):
        total_pages += block[i] * (2**i)

    free_blocks = 0
    for i in range(alloc_index, max_alloc_index):
        free_blocks += block[i] * 2**(i)

    print('Fragmentation Index for {}: {:.3f}'.format(name, (1 - free_blocks/total_pages)))


