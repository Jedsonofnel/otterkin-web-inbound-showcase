class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere
  routing(/^introduction@/i => :introductions)
end
