require 'spec_helper'
require 'backend_shared_example'

RSpec.describe MultiZip do
  if test_with_rubyzip?
    # it_behaves_like 'zip backend', 'rubyzip'
  end
end