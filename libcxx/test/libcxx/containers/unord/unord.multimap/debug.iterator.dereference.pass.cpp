//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <unordered_map>

// Dereference non-dereferenceable iterator.

// REQUIRES: has-unix-headers
// UNSUPPORTED: !libcpp-has-legacy-debug-mode, c++03

#include <string>
#include <unordered_map>

#include "check_assertion.h"
#include "min_allocator.h"

int main(int, char**) {
    {
        typedef std::unordered_multimap<int, std::string> C;
        C c;
        c.insert(std::make_pair(1, "one"));
        C::iterator i = c.end();
        TEST_LIBCPP_ASSERT_FAILURE(*i, "Attempted to dereference a non-dereferenceable unordered container iterator");
    }

    {
        typedef std::unordered_multimap<int, std::string, std::hash<int>, std::equal_to<int>,
                                        min_allocator<std::pair<const int, std::string>>> C;
        C c;
        c.insert(std::make_pair(1, "one"));
        C::iterator i = c.end();
        TEST_LIBCPP_ASSERT_FAILURE(*i, "Attempted to dereference a non-dereferenceable unordered container iterator");
    }

    return 0;
}
