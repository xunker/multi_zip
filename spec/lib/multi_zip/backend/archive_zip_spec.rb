require 'spec_helper'
require 'backend_shared_example'

RSpec.describe MultiZip do
  it_behaves_like 'zip backend', 'archive_zip'
end