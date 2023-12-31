//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// UNSUPPORTED: c++03, c++11, c++14, c++17

// <chrono>
// class year_month_weekday;

// constexpr year_month_weekday operator+(const year_month_weekday& ymd, const months& dm) noexcept;
//   Returns: (ymd.year() / ymd.month() + dm) / ymd.day().
//
// constexpr year_month_weekday operator+(const months& dm, const year_month_weekday& ymd) noexcept;
//   Returns: ymd + dm.
//
//
// constexpr year_month_weekday operator+(const year_month_weekday& ymd, const years& dy) noexcept;
//   Returns: (ymd.year() + dy) / ymd.month() / ymd.day().
//
// constexpr year_month_weekday operator+(const years& dy, const year_month_weekday& ymd) noexcept;
//   Returns: ym + dm.

#include <chrono>
#include <type_traits>
#include <cassert>

#include "test_macros.h"

using year               = std::chrono::year;
using month              = std::chrono::month;
using weekday            = std::chrono::weekday;
using weekday_indexed    = std::chrono::weekday_indexed;
using year_month_weekday = std::chrono::year_month_weekday;
using years              = std::chrono::years;
using months             = std::chrono::months;

constexpr bool test() {
  constexpr weekday Tuesday = std::chrono::Tuesday;
  constexpr month January   = std::chrono::January;

  { // year_month_weekday + months (and switched)
    year_month_weekday ym{year{1234}, January, weekday_indexed{Tuesday, 3}};
    for (int i = 0; i <= 10; ++i) // TODO test wrap-around
    {
      year_month_weekday ym1 = ym + months{i};
      year_month_weekday ym2 = months{i} + ym;
      assert(static_cast<int>(ym1.year()) == 1234);
      assert(static_cast<int>(ym2.year()) == 1234);
      assert(ym1.month() == month(1 + i));
      assert(ym2.month() == month(1 + i));
      assert(ym1.weekday() == Tuesday);
      assert(ym2.weekday() == Tuesday);
      assert(ym1.index() == 3);
      assert(ym2.index() == 3);
      assert(ym1 == ym2);
    }
  }

  { // year_month_weekday + years (and switched)
    year_month_weekday ym{year{1234}, std::chrono::January, weekday_indexed{Tuesday, 3}};
    for (int i = 0; i <= 10; ++i) {
      year_month_weekday ym1 = ym + years{i};
      year_month_weekday ym2 = years{i} + ym;
      assert(static_cast<int>(ym1.year()) == i + 1234);
      assert(static_cast<int>(ym2.year()) == i + 1234);
      assert(ym1.month() == January);
      assert(ym2.month() == January);
      assert(ym1.weekday() == Tuesday);
      assert(ym2.weekday() == Tuesday);
      assert(ym1.index() == 3);
      assert(ym2.index() == 3);
      assert(ym1 == ym2);
    }
  }

  return true;
}

int main(int, char**) {
  // year_month_weekday + months (and switched)
  ASSERT_NOEXCEPT(std::declval<year_month_weekday>() + std::declval<months>());
  ASSERT_NOEXCEPT(std::declval<months>() + std::declval<year_month_weekday>());

  ASSERT_SAME_TYPE(year_month_weekday, decltype(std::declval<year_month_weekday>() + std::declval<months>()));
  ASSERT_SAME_TYPE(year_month_weekday, decltype(std::declval<months>() + std::declval<year_month_weekday>()));

  // year_month_weekday + years (and switched)
  ASSERT_NOEXCEPT(std::declval<year_month_weekday>() + std::declval<years>());
  ASSERT_NOEXCEPT(std::declval<years>() + std::declval<year_month_weekday>());

  ASSERT_SAME_TYPE(year_month_weekday, decltype(std::declval<year_month_weekday>() + std::declval<years>()));
  ASSERT_SAME_TYPE(year_month_weekday, decltype(std::declval<years>() + std::declval<year_month_weekday>()));

  test();
  static_assert(test());

  return 0;
}
