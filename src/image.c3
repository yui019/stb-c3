module image;

import libc;

distinct DesiredChannels = int;
const DesiredChannels DEFAULT    = 0;
const DesiredChannels GREY       = 1;
const DesiredChannels GREY_ALPHA = 2;
const DesiredChannels RGB        = 3;
const DesiredChannels RGB_ALPHA  = 4;

//////////////////////////////////////////////////////////////////////////////
//
// PRIMARY API - works on images of any type
//

//
// load image by filename, open file, or memory buffer
//

def IoCallbacksReadFunc = fn int(void *user, char *data, int size);
def IoCallbacksSkipFunc = fn void(void *user, int n);
def IoCallbacksEofFunc = fn int(void *user);
struct IoCallbacks {
    IoCallbacksReadFunc read; // fill 'data' with 'size' bytes.  return number of bytes actually read
    IoCallbacksSkipFunc skip; // skip the next 'n' bytes, or 'unget' the last -n bytes if negative
    IoCallbacksEofFunc eof; // returns nonzero if we are at end of file/data
}

////////////////////////////////////
//
// 8-bits-per-channel interface
//

extern fn char *load_from_memory(char *buffer, int len   , int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_load_from_memory");
extern fn char *load_from_callbacks(IoCallbacks *clbk  , void *user, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_load_from_callbacks");

///#ifndef STBI_NO_STDIO
extern fn char *load(ZString filename, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_load");
extern fn char *load_from_file(CFile *f, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_load_from_file");
// for stbi_load_from_file, file pointer is left pointing immediately after image
///#endif

///#ifndef STBI_NO_GIF
extern fn char *load_gif_from_memory(char *buffer, int len, int **delays, int *x, int *y, int *z, int *comp, int req_comp) @extern("stbi_load_gif_from_memory");
///#endif

///#ifdef STBI_WINDOWS_UTF8
///extern fn int stbi_convert_wchar_to_utf8(char *buffer, size_t bufferlen, const wchar_t* input);
///#endif

////////////////////////////////////
//
// 16-bits-per-channel interface
//

extern fn short *load_16_from_memory(char *buffer, int len, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_load_16_from_memory");
extern fn short *load_16_from_callbacks(IoCallbacks *clbk, void *user, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_load_16_from_callbacks");

///#ifndef STBI_NO_STDIO
extern fn short *load_16(ZString filename, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_load_16");
extern fn short *load_from_file_16(CFile *f, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_load_from_file_16");
///#endif

////////////////////////////////////
//
// float-per-channel interface
//
///#ifndef STBI_NO_LINEAR
   extern fn float *loadf_from_memory(char *buffer, int len, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_loadf_from_memory");
   extern fn float *loadf_from_callbacks(IoCallbacks *clbk, void *user, int *x, int *y,  int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_loadf_from_callbacks");

   ///#ifndef STBI_NO_STDIO
   extern fn float *loadf(ZString filename, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_loadf");
   extern fn float *loadf_from_file(CFile *f, int *x, int *y, int *channels_in_file, DesiredChannels desired_channels) @extern("stbi_loadf_from_file");
   ///#endif
///#endif

///#ifndef STBI_NO_HDR
   extern fn void hdr_to_ldr_gamma(float gamma) @extern("stbi_hdr_to_ldr_gamma");
   extern fn void hdr_to_ldr_scale(float scale) @extern("stbi_hdr_to_ldr_scale");
///#endif // STBI_NO_HDR

///#ifndef STBI_NO_LINEAR
   extern fn void ldr_to_hdr_gamma(float gamma) @extern("stbi_ldr_to_hdr_gamma");
   extern fn void ldr_to_hdr_scale(float scale) @extern("stbi_ldr_to_hdr_scale");
///#endif // STBI_NO_LINEAR

// stbi_is_hdr is always defined, but always returns false if STBI_NO_HDR
extern fn int is_hdr_from_callbacks(IoCallbacks *clbk, void *user) @extern("stbi_is_hdr_from_callbacks");
extern fn int is_hdr_from_memory(char *buffer, int len) @extern("stbi_is_hdr_from_memory");
///#ifndef STBI_NO_STDIO
extern fn int is_hdr(ZString filename) @extern("stbi_is_hdr");
extern fn int is_hdr_from_file(CFile *f) @extern("stbi_is_hdr_from_file");
///#endif // STBI_NO_STDIO


// get a VERY brief reason for failure
// on most compilers (and ALL modern mainstream compilers) this is threadsafe
extern fn ZString failure_reason() @extern("stbi_failure_reason");

// free the loaded image -- this is just free()
extern fn void image_free(void *retval_from_stbi_load) @extern("stbi_image_free");

// get image dimensions & components without fully decoding
extern fn int info_from_memory(char *buffer, int len, int *x, int *y, int *comp) @extern("stbi_info_from_memory");
extern fn int info_from_callbacks(IoCallbacks *clbk, void *user, int *x, int *y, int *comp) @extern("stbi_info_from_callbacks");
extern fn int is_16_bit_from_memory(char *buffer, int len) @extern("stbi_is_16_bit_from_memory");
extern fn int is_16_bit_from_callbacks(IoCallbacks *clbk, void *user) @extern("stbi_is_16_bit_from_callbacks");

///#ifndef STBI_NO_STDIO
extern fn int info(ZString filename, int *x, int *y, int *comp) @extern("stbi_info");
extern fn int info_from_file(CFile *f, int *x, int *y, int *comp) @extern("stbi_info_from_file");
extern fn int is_16_bit(ZString filename) @extern("stbi_is_16_bit");
extern fn int is_16_bit_from_file(CFile *f) @extern("stbi_is_16_bit_from_file");
///#endif



// for image formats that explicitly notate that they have premultiplied alpha,
// we just return the colors as stored in the file. set this flag to force
// unpremultiplication. results are undefined if the unpremultiply overflow.
extern fn void set_unpremultiply_on_load(int flag_true_if_should_unpremultiply) @extern("stbi_set_unpremultiply_on_load");

// indicate whether we should process iphone images back to canonical format,
// or just pass them through "as-is"
extern fn void convert_iphone_png_to_rgb(int flag_true_if_should_convert) @extern("stbi_convert_iphone_png_to_rgb");

// flip the image vertically, so the first pixel in the output array is the bottom left
extern fn void set_flip_vertically_on_load(int flag_true_if_should_flip) @extern("stbi_set_flip_vertically_on_load");

// as above, but only applies to images loaded on the thread that calls the function
// this function is only available if your compiler supports thread-local variables;
// calling it will fail to link if your compiler doesn't
extern fn void set_unpremultiply_on_load_thread(int flag_true_if_should_unpremultiply) @extern("stbi_set_unpremultiply_on_load_thread");
extern fn void convert_iphone_png_to_rgb_thread(int flag_true_if_should_convert) @extern("stbi_convert_iphone_png_to_rgb_thread");
extern fn void set_flip_vertically_on_load_thread(int flag_true_if_should_flip) @extern("stbi_set_flip_vertically_on_load_thread");

// ZLIB client - used by PNG, available for other purposes

extern fn char *zlib_decode_malloc_guesssize(char *buffer, int len, int initial_size, int *outlen) @extern("stbi_zlib_decode_malloc_guesssize");
extern fn char *zlib_decode_malloc_guesssize_headerflag(char *buffer, int len, int initial_size, int *outlen, int parse_header) @extern("stbi_zlib_decode_malloc_guesssize_headerflag");
extern fn char *zlib_decode_malloc(char *buffer, int len, int *outlen) @extern("stbi_zlib_decode_malloc");
extern fn int zlib_decode_buffer(char *obuffer, int olen, char *ibuffer, int ilen) @extern("stbi_zlib_decode_buffer");

extern fn char *zlib_decode_noheader_malloc(char *buffer, int len, int *outlen) @extern("stbi_zlib_decode_noheader_malloc");
extern fn int zlib_decode_noheader_buffer(char *obuffer, int olen, char *ibuffer, int ilen) @extern("stbi_zlib_decode_noheader_buffer");