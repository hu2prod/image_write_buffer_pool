module = @
class @Image_write_buffer_pool
  log2_default_size : 1
  buf_list_list : []
  
  # 131072
  constructor : (default_size = 1<<17)->
    if "number" != typeof default_size
      throw new Error "'number' != typeof default_size"
    
    if default_size <= 0
      throw new Error "default_size <= 0"
    
    @log2_default_size = Math.ceil Math.log2 default_size
  
  buf_alloc_max : ()->
    for idx in [@buf_list_list.length - 1 .. 0] by -1
      list = @buf_list_list[idx]
      if list.length
        return list.pop()
    @buf_alloc()
  
  buf_alloc : (size)->
    if !size
      return @_buf_alloc_log2 @log2_default_size
    log2_size = Math.ceil Math.log2 size
    @_buf_alloc_log2 log2_size
  
  _buf_alloc_log2 : (log2_size)->
    log2_size = Math.max log2_size, @log2_default_size
    buf = Buffer.alloc 1 << log2_size
    
    # ensure buf_list_list size
    # after free there would be place for that
    for i in [@buf_list_list.length .. log2_size] by 1
      if !@buf_list_list[i]
        @buf_list_list.push []
    
    buf
  
  buf_get : (size)->
    log2_size = Math.ceil Math.log2 size
    @_buf_add_log2 log2_size
  
  _buf_get_log2 : (log2_size)->
    list = @buf_list_list[log2_size]
    if !list or list.length == 0
      return @_buf_alloc_log2 log2_size
    
    list.pop()
  
  buf_free : (buf, ext_alloc = false)->
    log2_size = Math.ceil Math.log2 buf.length
    list = @buf_list_list[log2_size]
    if !list
      if !ext_alloc
        perr "WARNING return buffer didn't find prepared place for store"
      @buf_list_list[log2_size] = list = []
    list.push buf
    return
  

class @Image_write_automation
  pool : null
  # encode_fn(img_buf, size_x, size_y, dst_buf, dst_buf_offset)
  constructor : (@encode_fn, default_size)->
    @pool = new module.Image_write_buffer_pool default_size
  
  encode : (src_img_data, src_size_x, src_size_y)->
    buf = @pool.buf_alloc_max()
    [dst_offset_start, dst_offset_end, dst_buf] = @encode_fn src_img_data, src_size_x, src_size_y, buf, 0
    if dst_buf != buf
      @pool.buf_free buf
      buf = dst_buf
    
    {
      buf : buf.slice dst_offset_start, dst_offset_end
      free : ()=>
        @pool.buf_free buf
    }
  
  encode_obj : (img)->
    encode img.data, img.size_x, img.size_y
  
  express_encode_send : (src_img_data, src_size_x, src_size_y, res)->
    {buf, free} = @encode src_img_data, src_size_x, src_size_y
    res.end buf, free
  
  express_encode_obj_send : (img, res)->
    @express_encode_send img.data, img.size_x, img.size_y, res
  
