# Submitting Your First Patch 

This document explains how to submit your first patch to Linux kernel.

## Selection of Upstream Repository
All git repositories hosted at kernel.org can be found at [https://git.kernel.org/](https://git.kernel.org/).

- Refer to [MAINTAINERS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/MAINTAINERS) located under Linux kernel source tree to find which repository should be used for your patch.
- Use kernel/git/torvalds/linux.git as the last resort if you cannnot find any entry that matches your requirement.

## Clone The Linux Kernel
Change the repository selected in previous step to your local working environment. \
Enable the signoff option of format-patch.

Example:
```
git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
git config --global format.signoff true
```

## Describe Your Patch
Using git format-patch to generate the subject & content of your emailed kernel patch is recommanded. \
However there are several things that you should pay attention to when you commit your change in local repository.

- Make sure -s option is included when using `git commit` to record your change.
- First line of your comment should following this format : `$subsystem: one-line summary`.
	* $subsystem: area of the kernel, or device driver, to which this patch applies.
	* one-line summary: summarizes the change this patch makes.
- Detailed comments follows the first line will be used as the content of your emailed patch.

Example:
```
mm/slab : replace open-coded round-up code with ALIGN

This patch makes use of ALIGN() to remove duplicate round-up code.

Signed-off-by: Canjiang Lu <canjiang.lu@samsung.com>
```

## Style Check
Refer to [Linux kernel coding style](https://www.kernel.org/doc/html/latest/process/coding-style.html#codingstyle) to adjust your change. \
Using patch style checker is another alternative.

Example:
```
bash$ ./scripts/checkpatch.pl -g HEAD
total: 0 errors, 0 warnings, 19 lines checked

Commit 8e5fc4f96c69 ("mm/slab : replace open-coded round-up code with ALIGN") has no obvious style problems and is ready for submission.
```

## Recipients for your patch
Using scripts/get_maintainer.pl to get maintainers. \
Andrew Morton (akpm@linux-foundation.org) serves as a maintainer of last resort.

Example:
```
bash$ git format-patch --stdout HEAD^ | ./scripts/get_maintainer.pl 
Christoph Lameter <cl@linux.com> (maintainer:SLAB ALLOCATOR)
Pekka Enberg <penberg@kernel.org> (maintainer:SLAB ALLOCATOR)
David Rientjes <rientjes@google.com> (maintainer:SLAB ALLOCATOR)
Joonsoo Kim <iamjoonsoo.kim@lge.com> (maintainer:SLAB ALLOCATOR)
Andrew Morton <akpm@linux-foundation.org> (maintainer:SLAB ALLOCATOR)
linux-mm@kvack.org (open list:SLAB ALLOCATOR)
linux-kernel@vger.kernel.org (open list)
```

## Generate Subject & Content
Example:
```
bash$ git format-patch --stdout HEAD^
From 8e5fc4f96c692d7e69ec0b474340c1be6c85cc8d Mon Sep 17 00:00:00 2001
From: Canjiang Lu <canjiang.lu@samsung.com>
Date: Fri, 7 Jul 2017 10:45:24 +0800
Subject: [PATCH] mm/slab : replace open-coded round-up code with ALIGN

This patch makes use of ALIGN() to remove duplicate round-up code.

Signed-off-by: Canjiang Lu <canjiang.lu@samsung.com>
---
 mm/slab.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2a31ee3..5033171 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2040,17 +2040,13 @@ static bool set_on_slab_cache(struct kmem_cache *cachep,
         * unaligned accesses for some archs when redzoning is used, and makes
         * sure any on-slab bufctl's are also correctly aligned.
         */
-       if (size & (BYTES_PER_WORD - 1)) {
-               size += (BYTES_PER_WORD - 1);
-               size &= ~(BYTES_PER_WORD - 1);
-       }
+       size = ALIGN(size, BYTES_PER_WORD);
 
        if (flags & SLAB_RED_ZONE) {
                ralign = REDZONE_ALIGN;
                /* If redzoning, ensure that the second redzone is suitably
                 * aligned, by adjusting the object size accordingly. */
-               size += REDZONE_ALIGN - 1;
-               size &= ~(REDZONE_ALIGN - 1);
+               size = ALIGN(size, REDZONE_ALIGN);
        }
 
        /* 3) caller mandated alignment */
-- 
1.9.1
```

## Email Your Patch
We use the output of previous step to manifest our email.

Subject
```
[PATCH] mm/slab : replace open-coded round-up code with ALIGN
```
Content
```
This patch makes use of ALIGN() to remove duplicate round-up code.

Signed-off-by: Canjiang Lu <canjiang.lu@samsung.com>
---
 mm/slab.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2a31ee3..5033171 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2040,17 +2040,13 @@ static bool set_on_slab_cache(struct kmem_cache *cachep,
         * unaligned accesses for some archs when redzoning is used, and makes
         * sure any on-slab bufctl's are also correctly aligned.
         */
-       if (size & (BYTES_PER_WORD - 1)) {
-               size += (BYTES_PER_WORD - 1);
-               size &= ~(BYTES_PER_WORD - 1);
-       }
+       size = ALIGN(size, BYTES_PER_WORD);
 
        if (flags & SLAB_RED_ZONE) {
                ralign = REDZONE_ALIGN;
                /* If redzoning, ensure that the second redzone is suitably
                 * aligned, by adjusting the object size accordingly. */
-               size += REDZONE_ALIGN - 1;
-               size &= ~(REDZONE_ALIGN - 1);
+               size = ALIGN(size, REDZONE_ALIGN);
        }
 
        /* 3) caller mandated alignment */
-- 
1.9.1

```

## Track Your Patch
Once your change is accepted by community, you can monitor it with [patchwork](https://patchwork.kernel.org/project/LKML/list/).

## References
- [Working with the kernel development community](https://www.kernel.org/doc/html/latest/process/index.html)
- [Submitting patches: the essential guide to getting your code into the kernel](https://www.kernel.org/doc/html/latest/process/submitting-patches.html)
- [Linux kernel patch format](http://linux.yyz.us/patch-format.html)
