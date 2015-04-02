require 'spec_helper'
require 'backend_shared_example'

RSpec.describe MultiZip::File do
  it_behaves_like 'zip backend', 'archive_zip'
end