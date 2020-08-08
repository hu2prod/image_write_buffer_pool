assert = require "assert"

mod = require "../src/index.coffee"

describe "pool section", ()->
  it "constructor", ()->
    new mod.Image_write_buffer_pool
    return
  
  describe "throws", ()->
    it "bad default size", ()->
      assert.throws ()->
        new mod.Image_write_buffer_pool 0
    
    it "bad default size 2", ()->
      assert.throws ()->
        new mod.Image_write_buffer_pool ""
  