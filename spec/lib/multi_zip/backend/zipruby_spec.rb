require 'spec_helper'
require 'backend_shared_example'

RSpec.describe MultiZip::File do
  if test_with_zipruby?
    it_behaves_like 'zip backend', 'zipruby'
  end
end