//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// UNSUPPORTED: no-threads
// UNSUPPORTED: c++03, c++11
// ALLOW_RETRIES: 2

// <shared_mutex>

// template <class Mutex> class shared_lock;

// explicit shared_lock(mutex_type& m);

// template<class _Mutex> shared_lock(shared_lock<_Mutex>)
//     -> shared_lock<_Mutex>;  // C++17

#include <cassert>
#include <chrono>
#include <cstdlib>
#include <shared_mutex>
#include <thread>
#include <vector>

#include "make_test_thread.h"
#include "test_macros.h"

typedef std::chrono::system_clock Clock;
typedef Clock::time_point time_point;
typedef Clock::duration duration;
typedef std::chrono::milliseconds ms;
typedef std::chrono::nanoseconds ns;

ms WaitTime = ms(250);

// Thread sanitizer causes more overhead and will sometimes cause this test
// to fail. To prevent this we give Thread sanitizer more time to complete the
// test.
#if !defined(TEST_IS_EXECUTED_IN_A_SLOW_ENVIRONMENT)
ms Tolerance = ms(50);
#else
ms Tolerance = ms(50 * 5);
#endif

std::shared_timed_mutex m;

void f()
{
    time_point t0 = Clock::now();
    time_point t1;
    {
    std::shared_lock<std::shared_timed_mutex> ul(m);
    t1 = Clock::now();
    }
    ns d = t1 - t0 - WaitTime;
    assert(d < Tolerance);  // within tolerance
}

void g()
{
    time_point t0 = Clock::now();
    time_point t1;
    {
    std::shared_lock<std::shared_timed_mutex> ul(m);
    t1 = Clock::now();
    }
    ns d = t1 - t0;
    assert(d < Tolerance);  // within tolerance
}

int main(int, char**)
{
    std::vector<std::thread> v;
    {
        m.lock();
        for (int i = 0; i < 5; ++i)
            v.push_back(support::make_test_thread(f));
        std::this_thread::sleep_for(WaitTime);
        m.unlock();
        for (auto& t : v)
            t.join();
    }
    {
        m.lock_shared();
        for (auto& t : v)
            t = support::make_test_thread(g);
        std::thread q = support::make_test_thread(f);
        std::this_thread::sleep_for(WaitTime);
        m.unlock_shared();
        for (auto& t : v)
            t.join();
        q.join();
    }

#if TEST_STD_VER >= 17
    std::shared_lock sl(m);
    static_assert((std::is_same<decltype(sl), std::shared_lock<decltype(m)>>::value), "" );
#endif

  return 0;
}
