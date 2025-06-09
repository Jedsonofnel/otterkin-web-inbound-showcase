class ApplicationRecord < ActiveRecord::Base
  include Filterable
  primary_abstract_class
end
