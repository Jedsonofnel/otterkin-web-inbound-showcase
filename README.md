# OTTERKIN WEB (SIMPLIFIED) REPO

This repository contains the bare bones of our Artist Draft feature
for our rails app.  I've totally gutted everything not directly relevant
to the feature for IP protection reasons (even if it's mostly basic
rails stuff) as it's for my startup, [Otterkin](https://otterkin.co.uk).

This is for the [Postmark inbound email competition](https://postmarkapp.com/blog/announcing-the-postmark-challenge-inbox-innovators).

## Feature Overview

We (Otterkin) are a UK based online art commissioning platform and
we're looking to build a bit of traction before the web app gets
launched properly and build a community of talented artists to enlist
on the platform when it's open.  The most natural way to allow artists
to get in touch after meeting them is definitely by sharing an email
address, and so we thought we could do something cool with the "hello"
emails we were getting in.  Thus the Artist Draft feature was born!

The basic flow goes:
1. Artist sends an email saying hi and introducing themselves to
<introduction@inbound.otterkin.co.uk>.

2. Postmark does it's magic and calls the Rails Action Mailbox
webhook with the email contents.

3. The mailbox creates a new ArtistDraft model with the email address
and uses Gemini AI and it's structured output feature to get some JSON
that fills in all required model fields.

4. This ArtistDraft is used for a fake Artist Profile page (think glossy
AirBnB listing page), the link to which is sent back to the Artist.

This means an Artist can easily visualise what their public artist 
profile may look like once the app is launched and can get excited about
it because it's a lot more visceral to interact with an actual website
than mockups or screenshots etc.  You can generate one yourself by
sending an email OR you can see an existing one [Here]()

## Code Overview

The interesting places to look are:
1. **app/mailboxes/introductions_mailbox.rb** - this is where the inbound
email magic happens.  It makes a new ArtistDraft, fills in the details
 with gemini, and includes any images the artist may have sent through
 too, and then sends an email back to the artist with the link.

2. **app/models/artist_draft.rb** - the model is responsible for
interacting with gemini which is the #extract_from_email_data method.
It also makes sure that at least 5 images are attached to properly
render the artist profile page.

3. **lib/gemini_client.rb** and **app/lib/gemini_schemas** - my
homemade gemini client as [RubyLLM](https://rubyllm.com/) doesn't yet
support structured output, which is essential to be able to use
an LLM to fill in a model.  In the schema file you can see the
structured output schema I want for my ArtistDraft.

4. **app/views/artist_drafts/show** - the artist draft page itself!
It'd probs make more sense to look at a live page - check out
[this](https://otterkin.co.uk/artist_drafts/4) one.
