module Pincers::Support
  class Cookie < Struct.new(:name, :value, :domain, :path, :expires, :secure); end
end