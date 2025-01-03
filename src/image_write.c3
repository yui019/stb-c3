module image_write;

///#ifndef STBI_WRITE_NO_STDIO
extern fn int write_png(ZString filename, int w, int h, int comp, void  *data, int stride_in_bytes) @extern("stbi_write_png");
extern fn int write_bmp(ZString filename, int w, int h, int comp, void  *data) @extern("stbi_write_bmp");
extern fn int write_tga(ZString filename, int w, int h, int comp, void  *data) @extern("stbi_write_tga");
extern fn int write_hdr(ZString filename, int w, int h, int comp, float *data) @extern("stbi_write_hdr");
extern fn int write_jpg(ZString filename, int x, int y, int comp, void  *data, int quality) @extern("stbi_write_jpg");

///#ifdef STBIW_WINDOWS_UTF8
///STBIWDEF int stbiw_convert_wchar_to_utf8(char *buffer, size_t bufferlen, const wchar_t* input);
///#endif

///#endif

def WriteFunc = fn void(void *context, void *data, int size);

extern fn int write_png_to_func(WriteFunc *func, void *context, int w, int h, int comp, void  *data, int stride_in_bytes) @extern("stbi_write_png_to_func");
extern fn int write_bmp_to_func(WriteFunc *func, void *context, int w, int h, int comp, void  *data) @extern("stbi_write_bmp_to_func");
extern fn int write_tga_to_func(WriteFunc *func, void *context, int w, int h, int comp, void  *data) @extern("stbi_write_tga_to_func");
extern fn int write_hdr_to_func(WriteFunc *func, void *context, int w, int h, int comp, float *data) @extern("stbi_write_hdr_to_func");
extern fn int write_jpg_to_func(WriteFunc *func, void *context, int x, int y, int comp, void  *data, int quality) @extern("stbi_write_jpg_to_func");

extern fn void flip_vertically_on_write(bool flip) @extern("stbi_flip_vertically_on_write");