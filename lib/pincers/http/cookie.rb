module Pincers::Http
  class Cookie < Struct.new(:name, :value, :domain, :path, :expires, :secure); end
end