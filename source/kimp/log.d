/**
 * Specific logger for the stickbot
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 24 Aig 2021
 */ 
module kimp.log;

import std.experimental.logger, std.stdio;
import std.algorithm : count;
import std.conv : to;

/** 
 * Specific logger for the stickbot
 */
class StickBotLogger : Logger {
    /** 
     * Init`s the logger
     */
    public this () @safe { super (LogLevel.info); }

    public override void writeLogMsg(ref LogEntry payload) @safe {
        if ([LogLevel.info, LogLevel.trace].count(payload.logLevel)) {
            writeln ("\033[32;1m[INFO]\033[0m [\033[33;4m", payload.timestamp.toString(), "\033[0m] [\033[36m", payload.moduleName, ':', payload.line, "\033[0m] " ~ payload.msg);
        } else if (LogLevel.warning == payload.logLevel) {
            writeln ("\033[33;1m[WARNING]\033[0m [\033[33;4m", payload.timestamp.toString(), "\033[0m] [\033[36m", payload.moduleName, ':', payload.line, "\033[0m] " ~ payload.msg);
        } else {
            writeln ("\033[31;1m[ERROR]\033[0m [\033[33;4m", payload.timestamp.toString(), "\033[0m] [\033[36m", payload.moduleName, ':', payload.line, "\033[0m] " ~ payload.msg);
        }
    } 
}
