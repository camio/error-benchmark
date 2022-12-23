#include <benchmark/benchmark.h>
#include <tl/expected.hpp>

#include <cstdlib>
#include <cstring>
#include <memory>
#include <system_error>

extern int conderror_ret(bool b);
extern tl::expected<int, std::error_code> conderror_exp(bool b);
extern int conderror_exc(bool b);

void BM_happy_ret(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<bool[]> a(new bool[N]);
    std::memset(a.get(), false, N*sizeof(bool));
    const bool* b = a.get();
    for (auto _ : state) {
        for (size_t i = 0; i<N; ++i)
          benchmark::DoNotOptimize(conderror_ret(b[i]));
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_happy_exp(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<bool[]> a(new bool[N]);
    std::memset(a.get(), false, N*sizeof(bool));
    const bool* b = a.get();
    for (auto _ : state) {
        for (size_t i = 0; i<N; ++i)
          benchmark::DoNotOptimize(conderror_exp(b[i]));
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_happy_exc(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<bool[]> a(new bool[N]);
    std::memset(a.get(), false, N*sizeof(bool));
    const bool* b = a.get();
    for (auto _ : state) {
        for (size_t i = 0; i<N; ++i)
          benchmark::DoNotOptimize(conderror_exc(b[i]));
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_sad_ret(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<bool[]> a(new bool[N]);
    std::memset(a.get(), true, N*sizeof(bool));
    const bool* b = a.get();
    int c = 0;

    for (auto _ : state) {
        for (size_t i = 0; i<N; ++i)
        {
          int r;
          benchmark::DoNotOptimize(r = conderror_ret(b[i]));
          if( r == -1 )
            benchmark::DoNotOptimize(++c);
        }
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_sad_exp(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<bool[]> a(new bool[N]);
    std::memset(a.get(), true, N*sizeof(bool));
    const bool* b = a.get();
    int c = 0;

    for (auto _ : state) {
        for (size_t i = 0; i<N; ++i)
        {
          tl::expected<int, std::error_code> r;
          benchmark::DoNotOptimize(r = conderror_exp(b[i]));
          if( !r )
            benchmark::DoNotOptimize(++c);
        }
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_sad_exc(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<bool[]> a(new bool[N]);
    std::memset(a.get(), true, N*sizeof(bool));
    const bool* b = a.get();
    int c = 0;

    for (auto _ : state) {
        for (size_t i = 0; i<N; ++i)
        {
          try {
            benchmark::DoNotOptimize(conderror_exc(b[i]));
          } catch (const std::system_error &e) {
            benchmark::DoNotOptimize(++c);
          }
        }
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_mix_ret(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<bool[]> a(new bool[N]);
    for(size_t i = 0; i < N; ++i)
      a.get()[i] = i%state.range(1) == 0;
    const bool* b = a.get();
    int c = 0;

    for (auto _ : state) {
        for (size_t i = 0; i<N; ++i)
        {
          int r;
          benchmark::DoNotOptimize(r = conderror_ret(b[i]));
          if( r == -1 )
            benchmark::DoNotOptimize(++c);
        }
    }
    state.SetItemsProcessed(N*state.iterations());
}
void BM_mix_exp(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<bool[]> a(new bool[N]);
    for(size_t i = 0; i < N; ++i)
      a.get()[i] = i%state.range(1) == 0;
    const bool* b = a.get();
    int c = 0;

    for (auto _ : state) {
        for (size_t i = 0; i<N; ++i)
        {
          tl::expected<int, std::error_code> r;
          benchmark::DoNotOptimize(r = conderror_exp(b[i]));
          if( !r )
            benchmark::DoNotOptimize(++c);
        }
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_mix_exc(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<bool[]> a(new bool[N]);
    for(size_t i = 0; i < N; ++i)
      a.get()[i] = i%state.range(1) == 0;
    const bool* b = a.get();
    int c = 0;

    for (auto _ : state) {
        for (size_t i = 0; i<N; ++i)
        {
          try {
            benchmark::DoNotOptimize(conderror_exc(b[i]));
          } catch (const std::system_error &e) {
            benchmark::DoNotOptimize(++c);
          }
        }
    }
    state.SetItemsProcessed(N*state.iterations());
}

#define ARGS \
    ->Arg( long(1e6) )

#define MIX_ARGS \
    ->Args( {long(1e6), long(1e4)} ) \
    ->Args( {long(1e6), long(1e3)} ) \
    ->Args( {long(1e6), long(1e2)} ) \
    ->Args( {long(1e6), long(1e1)} )

BENCHMARK(BM_happy_ret) ARGS;
BENCHMARK(BM_happy_exp) ARGS;
BENCHMARK(BM_happy_exc) ARGS;
BENCHMARK(BM_mix_ret) MIX_ARGS;
BENCHMARK(BM_mix_exp) MIX_ARGS;
BENCHMARK(BM_mix_exc) MIX_ARGS;
BENCHMARK(BM_sad_ret) ARGS;
BENCHMARK(BM_sad_exp) ARGS;
BENCHMARK(BM_sad_exc) ARGS;

BENCHMARK_MAIN();
