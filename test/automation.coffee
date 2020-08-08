assert = require "assert"
fs = require "fs"

mod = require "../src/index.coffee"
napi_png = require "napi_png"

describe "pool section", ()->
  automation = null
  it "constructor", ()->
    automation = new mod.Image_write_automation napi_png.png_encode_rgba
    return
  
  it "use", ()->
    png_buf = fs.readFileSync "test/img/photoshop.png"
    [size_x, size_y] = napi_png.png_decode_size png_buf
    raw_buf = Buffer.alloc(4*size_x*size_y)
    napi_png.png_decode_rgba png_buf, raw_buf
    
    for i in [0 ... 5]
      {buf, free} = automation.encode raw_buf, size_x, size_y
      raw_buf2 = Buffer.alloc(4*size_x*size_y)
      napi_png.png_decode_rgba buf, raw_buf2
      
      free()
      assert 0 == Buffer.compare raw_buf, raw_buf2
    
    return
  
  it "use low size", ()->
    automation = new mod.Image_write_automation napi_png.png_encode_rgba, 1024
    png_buf = fs.readFileSync "test/img/photoshop.png"
    [size_x, size_y] = napi_png.png_decode_size png_buf
    raw_buf = Buffer.alloc(4*size_x*size_y)
    napi_png.png_decode_rgba png_buf, raw_buf
    
    for i in [0 ... 5]
      {buf, free} = automation.encode raw_buf, size_x, size_y
      raw_buf2 = Buffer.alloc(4*size_x*size_y)
      napi_png.png_decode_rgba buf, raw_buf2
      
      free()
      assert 0 == Buffer.compare raw_buf, raw_buf2
    
    return
  