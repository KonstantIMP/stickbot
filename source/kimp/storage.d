/**
 * Module for tmp files managing
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 12 Aug 2021
 */
module kimp.storage;

import std.file, std.uuid, std.path;

/** 
 * Class for working with tmp files
 */
class TmpStorage {
    /** 
     * Generate unused name for tmp file
     * Returns: Generated filename
     */
    static public string genTmpFile () {
        string tmpDir = tempDir();

        string fileName = randomUUID().toString() ~ ".tmp";

        while (exists (tmpDir ~ pathSeparator ~ fileName)) {
            fileName = randomUUID().toString() ~ ".tmp";
        }

        return fileName;
    }
}
