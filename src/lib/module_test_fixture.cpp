// These globals are used to pass command line options into the test fixture.  These are global and
// not static members because the test fixture class is templated based on the Verilated module.
const char *g_trace_directory = nullptr;
