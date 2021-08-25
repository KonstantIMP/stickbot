// Split function for std::string
// Author: KonstantIMP <mihedovkos@gmail.com>
// Date: 9 Aug 2021
#pragma once

#include <string>
#include <vector>

namespace kimp {

/**
 * @brief Split the string by the delimiter
 * @param[in] s String for split
 * @param[in] delimiter Delimiter for split
 * @return Vector with splitted strings
 */
std::vector<std::string> split(const std::string& s, char delimiter);

} // namespace kimp
