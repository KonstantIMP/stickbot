/**
 * Ctrl+C handler for loop exit
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 26 Aug 2021
 */
module kimp.exit;

private import core.stdc.stdlib;

private void delegate() nothrow @nogc _ccallback;
private extern (C) void handle (int sig) nothrow @nogc @system { _ccallback(); exit (0); }

/** 
 * Runs delegate in the scoped space
 * Params:
 *   task = Delegate for execute
 *   callback = Delegate for run befire exit
 */
public void exitScope (void delegate() task, void delegate() nothrow @nogc @system callback) {
    version (Windows) {
        scope (exit) { callback(); }
        task();
    }
    else {
        import core.sys.posix.signal;

        _ccallback = callback; signal(2, &handle);

        task();
    }
} 
