// Minimal kernel module for build environment test
#include <linux/module.h>
#include <linux/init.h>

static int __init test_init(void) {
    pr_info("test_module: loaded\n");
    return 0;
}

static void __exit test_exit(void) {
    pr_info("test_module: unloaded\n");
}

module_init(test_init);
module_exit(test_exit);
MODULE_LICENSE("GPL");
