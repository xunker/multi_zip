require 'spec_helper'
require 'backend_shared_example'

RSpec.describe MultiZip do
  if test_with_archive_zip?
    # it_behaves_like 'zip backend', 'archive_zip'
  end
end