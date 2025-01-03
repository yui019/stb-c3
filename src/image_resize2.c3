module image_resize_2;

// PixelLayout specifies:
//   number of channels
//   order of channels
//   whether color is premultiplied by alpha
// for back compatibility, you can cast the old channel count to a PixelLayout
distinct PixelLayout = int;

const PixelLayout PIXEL_LAYOUT_1CHANNEL = 1;
const PixelLayout PIXEL_LAYOUT_2CHANNEL = 2;
const PixelLayout PIXEL_LAYOUT_RGB      = 3; // 3-chan, with order specified (for channel flipping)
const PixelLayout PIXEL_LAYOUT_BGR      = 0; // 3-chan, with order specified (for channel flipping)
const PixelLayout PIXEL_LAYOUT_4CHANNEL = 5;

const PixelLayout PIXEL_LAYOUT_RGBA = 4; // alpha formats, where alpha is NOT premultiplied into color channels
const PixelLayout PIXEL_LAYOUT_BGRA = 6;
const PixelLayout PIXEL_LAYOUT_ARGB = 7;
const PixelLayout PIXEL_LAYOUT_ABGR = 8;
const PixelLayout PIXEL_LAYOUT_RA   = 9;
const PixelLayout PIXEL_LAYOUT_AR   = 10;

const PixelLayout PIXEL_LAYOUT_RGBA_PM = 11; // alpha formats, where alpha is premultiplied into color channels
const PixelLayout PIXEL_LAYOUT_BGRA_PM = 12;
const PixelLayout PIXEL_LAYOUT_ARGB_PM = 13;
const PixelLayout PIXEL_LAYOUT_ABGR_PM = 14;
const PixelLayout PIXEL_LAYOUT_RA_PM   = 15;
const PixelLayout PIXEL_LAYOUT_AR_PM   = 16;

const PixelLayout PIXEL_LAYOUT_RGBA_NO_AW = 11; // alpha formats, where NO alpha weighting is applied at all!
const PixelLayout PIXEL_LAYOUT_BGRA_NO_AW = 12; //   these are just synonyms for the _PM flags (which also do
const PixelLayout PIXEL_LAYOUT_ARGB_NO_AW = 13; //   no alpha weighting). These names just make it more clear
const PixelLayout PIXEL_LAYOUT_ABGR_NO_AW = 14; //   for some folks).
const PixelLayout PIXEL_LAYOUT_RA_NO_AW   = 15;
const PixelLayout PIXEL_LAYOUT_AR_NO_AW   = 16;


//===============================================================
//  Simple-complexity API
//
//    If output_pixels is NULL (0), then we will allocate the buffer and return it to you.
//--------------------------------

extern fn char * stbir_resize_uint8_srgb(char *input_pixels , int input_w , int input_h, int input_stride_in_bytes, char *output_pixels, int output_w, int output_h, int output_stride_in_bytes, PixelLayout pixel_type) @extern("stbir_resize_uint8_srgb");

extern fn char * stbir_resize_uint8_linear(char *input_pixels , int input_w , int input_h, int input_stride_in_bytes, char *output_pixels, int output_w, int output_h, int output_stride_in_bytes, PixelLayout pixel_type) @extern("stbir_resize_uint8_linear");

extern fn float * stbir_resize_float_linear(float *input_pixels , int input_w , int input_h, int input_stride_in_bytes, float *output_pixels, int output_w, int output_h, int output_stride_in_bytes, PixelLayout pixel_type) @extern("stbir_resize_float_linear");
//===============================================================

//===============================================================
// Medium-complexity API
//
// This extends the easy-to-use API as follows:
//
//     * Can specify the datatype - U8, U8_SRGB, U16, FLOAT, HALF_FLOAT
//     * Edge wrap can selected explicitly
//     * Filter can be selected explicitly
//--------------------------------

distinct Edge = int;
const Edge EDGE_CLAMP = 0;
const Edge EDGE_REFLECT = 1;
const Edge EDGE_WRAP = 2;  // this edge mode is slower and uses more memory
const Edge EDGE_ZERO = 3;

distinct Filter = int;
const Filter FILTER_DEFAULT = 0;  // use same filter type that easy-to-use API chooses
const Filter FILTER_BOX = 1;  // A trapezoid w/1-pixel wide ramps, same result as box for integer scale ratios
const Filter FILTER_TRIANGLE = 2;  // On upsampling, produces same results as bilinear texture filtering
const Filter FILTER_CUBICBSPLINE = 3;  // The cubic b-spline (aka Mitchell-Netrevalli with B=1,C=0), gaussian-esque
const Filter FILTER_CATMULLROM = 4;  // An interpolating cubic spline
const Filter FILTER_MITCHELL = 5;  // Mitchell-Netrevalli filter with B=1/3, C=1/3
const Filter FILTER_POINT_SAMPLE = 6;  // Simple point sampling
const Filter FILTER_OTHER = 7;  // User callback specified

distinct Datatype = int;
const Datatype TYPE_UINT8 = 0;
const Datatype TYPE_UINT8_SRGB = 1;
const Datatype TYPE_UINT8_SRGB_ALPHA = 2;  // alpha channel, when present, should also be SRGB (this is very unusual)
const Datatype TYPE_UINT16 = 3;
const Datatype TYPE_FLOAT = 4;
const Datatype TYPE_HALF_FLOAT = 5;

// medium api
extern fn void * resize(void *input_pixels, int input_w, int input_h, int input_stride_in_bytes, void *output_pixels, int output_w, int output_h, int output_stride_in_bytes, PixelLayout pixel_layout, Datatype data_type, Edge edge, Filter filter) @extern("stbir_resize");
//===============================================================



//===============================================================
// Extended-complexity API
//
// This API exposes all resize functionality.
//
//     * Separate filter types for each axis
//     * Separate edge modes for each axis
//     * Separate input and output data types
//     * Can specify regions with subpixel correctness
//     * Can specify alpha flags
//     * Can specify a memory callback
//     * Can specify a callback data type for pixel input and output
//     * Can be threaded for a single resize
//     * Can be used to resize many frames without recalculating the sampler info
//
//  Use this API as follows:
//     1) Call the stbir_resize_init function on a local STBIR_RESIZE structure
//     2) Call any of the stbir_set functions
//     3) Optionally call stbir_build_samplers() if you are going to resample multiple times
//        with the same input and output dimensions (like resizing video frames)
//     4) Resample by calling stbir_resize_extended().
//     5) Call stbir_free_samplers() if you called stbir_build_samplers()
//--------------------------------


// Types:

// INPUT CALLBACK: this callback is used for input scanlines
def InputCallback = fn void*(void * optional_output, void * input_ptr, int num_pixels, int x, int y, void * context);

// OUTPUT CALLBACK: this callback is used for output scanlines
def OutputCallback = fn void(void * output_ptr, int num_pixels, int y, void * context);

// callbacks for user installed filters
def KernelCallback = fn float(float x, float scale, void * user_data); // centered at zero
def SupportCallback = fn float(float scale, void * user_data);

// internal structure with precomputed scaling
distinct Info = void;

struct Resize  // use the stbir_resize_init and stbir_override functions to set these values for future compatibility
{
  void * user_data;
  void * input_pixels;
  int input_w, input_h;
  double input_s0, input_t0, input_s1, input_t1;
  InputCallback * input_cb;
  void * output_pixels;
  int output_w, output_h;
  int output_subx, output_suby, output_subw, output_subh;
  OutputCallback * output_cb;
  int input_stride_in_bytes;
  int output_stride_in_bytes;
  int splits;
  int fast_alpha;
  int needs_rebuild;
  int called_alloc;
  PixelLayout input_pixel_layout_public;
  PixelLayout output_pixel_layout_public;
  Datatype input_data_type;
  Datatype output_data_type;
  Filter horizontal_filter, vertical_filter;
  Edge horizontal_edge, vertical_edge;
  KernelCallback * horizontal_filter_kernel;
  SupportCallback * horizontal_filter_support;
  KernelCallback * vertical_filter_kernel;
  SupportCallback * vertical_filter_support;
  Info * samplers;
}

// extended complexity api


// First off, you must ALWAYS call stbir_resize_init on your resize structure before any of the other calls!
// input_stride_in_bytes can be zero
// output_stride_in_bytes can be zero
extern fn void resize_init(Resize * resize, void *input_pixels, int input_w, int input_h, int input_stride_in_bytes, void *output_pixels, int output_w, int output_h, int output_stride_in_bytes, PixelLayout pixel_layout, Datatype data_type) @extern("stbir_resize_init");

//===============================================================
// You can update these parameters any time after resize_init and there is no cost
//--------------------------------

extern fn void set_datatypes(Resize * resize, Datatype input_type, Datatype output_type) @extern("stbir_set_datatypes");
extern fn void set_pixel_callbacks(Resize * resize, InputCallback * input_cb, OutputCallback * output_cb) @extern("stbir_set_pixel_callbacks"); // no callbacks by default
extern fn void set_user_data(Resize * resize, void * user_data) @extern("stbir_set_user_data"); // pass back STBIR_RESIZE* by default
extern fn void set_buffer_ptrs(Resize * resize, void * input_pixels, int input_stride_in_bytes, void * output_pixels, int output_stride_in_bytes) @extern("stbir_set_buffer_ptrs");

//===============================================================


//===============================================================
// If you call any of these functions, you will trigger a sampler rebuild!
//--------------------------------

extern fn int set_pixel_layouts(Resize * resize, PixelLayout input_pixel_layout, PixelLayout output_pixel_layout) @extern("stbir_set_pixel_layouts"); // sets new buffer layouts
extern fn int set_edgemodes(Resize * resize, Edge horizontal_edge, Edge vertical_edge) @extern("stbir_set_edgemodes"); // CLAMP by default

extern fn int set_filters(Resize * resize, Filter horizontal_filter, Filter vertical_filter) @extern("stbir_set_filters"); // STBIR_DEFAULT_FILTER_UPSAMPLE/DOWNSAMPLE by default
extern fn int set_filter_callbacks(Resize * resize, KernelCallback * horizontal_filter, SupportCallback * horizontal_support, KernelCallback * vertical_filter, SupportCallback * vertical_support) @extern("stbir_set_filter_callbacks");

extern fn int set_pixel_subrect(Resize * resize, int subx, int suby, int subw, int subh) @extern("stbir_set_pixel_subrect"); // sets both sub-regions (full regions by default)
extern fn int set_input_subrect(Resize * resize, double s0, double t0, double s1, double t1) @extern("stbir_set_input_subrect"); // sets input sub-region (full region by default)
extern fn int set_output_pixel_subrect(Resize * resize, int subx, int suby, int subw, int subh) @extern("stbir_set_output_pixel_subrect"); // sets output sub-region (full region by default)

// when inputting AND outputting non-premultiplied alpha pixels, we use a slower but higher quality technique
//   that fills the zero alpha pixel's RGB values with something plausible.  If you don't care about areas of
//   zero alpha, you can call this function to get about a 25% speed improvement for STBIR_RGBA to STBIR_RGBA
//   types of resizes.
extern fn int set_non_pm_alpha_speed_over_quality(Resize * resize, int non_pma_alpha_speed_over_quality) @extern("stbir_set_non_pm_alpha_speed_over_quality");
//===============================================================


//===============================================================
// You can call build_samplers to prebuild all the internal data we need to resample.
//   Then, if you call resize_extended many times with the same resize, you only pay the
//   cost once.
// If you do call build_samplers, you MUST call free_samplers eventually.
//--------------------------------

// This builds the samplers and does one allocation
extern fn int build_samplers(Resize * resize) @extern("stbir_build_samplers");

// You MUST call this, if you call stbir_build_samplers or stbir_build_samplers_with_splits
extern fn void free_samplers(Resize * resize) @extern("stbir_free_samplers");
//===============================================================


// And this is the main function to perform the resize synchronously on one thread.
extern fn int resize_extended(Resize * resize) @extern("stbir_resize_extended");


//===============================================================
// Use these functions for multithreading.
//   1) You call stbir_build_samplers_with_splits first on the main thread
//   2) Then stbir_resize_with_split on each thread
//   3) stbir_free_samplers when done on the main thread
//--------------------------------

// This will build samplers for threading.
//   You can pass in the number of threads you'd like to use (try_splits).
//   It returns the number of splits (threads) that you can call it with.
///  It might be less if the image resize can't be split up that many ways.

extern fn int build_samplers_with_splits(Resize * resize, int try_splits) @extern("stbir_build_samplers_with_splits");

// This function does a split of the resizing (you call this fuction for each
// split, on multiple threads). A split is a piece of the output resize pixel space.

// Note that you MUST call stbir_build_samplers_with_splits before stbir_resize_extended_split!

// Usually, you will always call stbir_resize_split with split_start as the thread_index
//   and "1" for the split_count.
// But, if you have a weird situation where you MIGHT want 8 threads, but sometimes
//   only 4 threads, you can use 0,2,4,6 for the split_start's and use "2" for the
//   split_count each time to turn in into a 4 thread resize. (This is unusual).

extern fn int stbir_resize_extended_split(Resize * resize, int split_start, int split_count) @extern("stbir_resize_extended_split");
//===============================================================


//===============================================================
// Pixel Callbacks info:
//--------------------------------

//   The input callback is super flexible - it calls you with the input address
//   (based on the stride and base pointer), it gives you an optional_output
//   pointer that you can fill, or you can just return your own pointer into
//   your own data.
//
//   You can also do conversion from non-supported data types if necessary - in
//   this case, you ignore the input_ptr and just use the x and y parameters to
//   calculate your own input_ptr based on the size of each non-supported pixel.
//   (Something like the third example below.)
//
//   You can also install just an input or just an output callback by setting the
//   callback that you don't want to zero.
//
//     First example, progress: (getting a callback that you can monitor the progress):
//        void const * my_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context )
//        {
//           percentage_done = y / input_height;
//           return input_ptr;  // use buffer from call
//        }
//
//     Next example, copying: (copy from some other buffer or stream):
//        void const * my_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context )
//        {
//           CopyOrStreamData( optional_output, other_data_src, num_pixels * pixel_width_in_bytes );
//           return optional_output;  // return the optional buffer that we filled
//        }
//
//     Third example, input another buffer without copying: (zero-copy from other buffer):
//        void const * my_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context )
//        {
//           void * pixels = ( (char*) other_image_base ) + ( y * other_image_stride ) + ( x * other_pixel_width_in_bytes );
//           return pixels;       // return pointer to your data without copying
//        }
//
//
//   The output callback is considerably simpler - it just calls you so that you can dump
//   out each scanline. You could even directly copy out to disk if you have a simple format
//   like TGA or BMP. You can also convert to other output types here if you want.
//
//   Simple example:
//        void const * my_output( void * output_ptr, int num_pixels, int y, void * context )
//        {
//           percentage_done = y / output_height;
//           fwrite( output_ptr, pixel_width_in_bytes, num_pixels, output_file );
//        }
//===============================================================


//===============================================================
// optional built-in profiling API
//--------------------------------

///#ifdef STBIR_PROFILE

struct ProfileInfo
{
  ulong total_clocks;

  // how many clocks spent (of total_clocks) in the various resize routines, along with a string description
  //    there are "resize_count" number of zones
  ulong[8] clocks;
  ZString* descriptions;

  // count of clocks and descriptions
  uint count;
}

// use after calling stbir_resize_extended (or stbir_build_samplers or stbir_build_samplers_with_splits)
extern fn void resize_build_profile_info(ProfileInfo * out_info, Resize * resize) @extern("stbir_resize_build_profile_info");

// use after calling stbir_resize_extended
extern fn void resize_extended_profile_info(ProfileInfo * out_info, Resize * resize) @extern("stbir_resize_extended_profile_info");

// use after calling stbir_resize_extended_split
extern fn void resize_split_profile_info(ProfileInfo * out_info, Resize * resize, int split_start, int split_num) @extern("stbir_resize_split_profile_info");

//===============================================================

///#endif