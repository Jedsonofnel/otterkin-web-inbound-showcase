# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "--- Seeding Tags ---"

TAG_DATA = {
  style: [
    # General & Historical Styles
    "Abstract", "Abstract Expressionism", "Academic Art", "Art Deco", "Art Nouveau",
    "Baroque", "Bauhaus", "Byzantine", "Classicism", "Constructivism", "Cubism",
    "Dadaism", "Expressionism", "Fauvism", "Figurative", "Folk Art", "Futurism",
    "Gothic", "High Renaissance", "Impressionism", "Mannerism", "Minimalism",
    "Modern Art", "Neoclassicism", "Op Art", "Pop Art", "Post-Impressionism",
    "Pre-Raphaelite", "Realism", "Regionalism", "Renaissance", "Rococo",
    "Romanticism", "Surrealism", "Symbolism", "Tonalism", "Traditional",
    "Victorian",

    # Contemporary & Digital Styles
    "Anime/Manga", "Caricature", "Cartoon", "Cel Shading", "Chibi",
    "Comics", "Concept Art", "Cyberpunk", "Digital Art", "Fantasy Art",
    "Game Art", "Graffiti", "Graphic Novel", "Hyperrealism", "Line Art", "Low Poly",
    "Pixel Art", "Pop Surrealism", "Sci-Fi Art", "Steampunk", "Street Art",
    "Stylized", "Technical Drawing", "Vector Art", "Voxel Art",

    # Specific Techniques / Aesthetics
    "Aestheticism", "Automatism", "Chiaroscuro", "En Plein Air", "Frottage",
    "Grisaille", "Impasto", "Japonisme", "Macabre", "Pointillism", "Pulp Art",
    "Sfumato", "Trompe L'oeil", "Ukiyo-e", "Vanitas"
  ],
  subject: [
    # People & Figures
    "Portraits", "Self-Portrait", "Figure Study", "Nude",
    "Children", "Family Portraits", "Group Portraits", "Historical Figures",
    "Mythological Figures", "Religious Figures", "Anatomy", "Character Design",

    # Animals & Nature
    "Animals", "Wildlife", "Domestic Animals", "Birds", "Fish",
    "Insects", "Marine Life", "Fantasy Creatures", "Botanical Art", "Floral Art",
    "Landscapes", "Cityscapes", "Seascapes", "Skyscapes", "Rural Landscapes",
    "Urban Landscapes", "Forests", "Mountains", "Rivers", "Lakes", "Gardens",
    "Still Life", "Food Art", "Fruit", "Vegetables", "Flowers", "Vases", "Books",
    "Musical Instruments", "Everyday Objects",

    # Architecture & Places
    "Architecture", "Buildings", "Interiors", "Exteriors", "Historical Buildings",
    "Abstract Architecture", "Ruins", "Street Scenes", "Landmarks", "Bridges",
    "Castles", "Cathedrals", "Cottages", "Skyscrapers", "Industrial Architecture",

    # Vehicles & Transportation
    "Vehicles", "Cars", "Motorcycles", "Bicycles", "Trains", "Planes",
    "Boats", "Ships", "Spaceships", "Vintage Vehicles", "Futuristic Vehicles",

    # Conceptual & Abstract Subjects
    "Abstract Subjects", "Dreams", "Emotions",
    "Narrative Art", "Symbolic Subjects", "Allegory", "Mythology", "Spirituality",
    "Sci-Fi Themes", "Fantasy Themes", "Horror Themes", "Humor",

    # Fan Art & Pop Culture
    "Fan Art", "Movie Characters", "TV Show Characters", "Video Game Characters",
    "Comic Book Characters", "Music Icons", "Book Characters", "Pop Culture Icons",

    # Miscellaneous
    "Maps", "Calligraphy", "Typography", "Illustrations", "Book Covers", "Album Art",
    "Poster Design", "Commissions", "Mural Art"
  ],
  medium: [
    # Painting
    "Oil Paint", "Acrylic Paint", "Watercolor", "Gouache", "Tempera", "Encaustic",
    "Fresco", "Ink Wash Painting", "Casein Paint", "Egg Tempera",

    # Drawing
    "Graphite Pencil", "Charcoal", "Colored Pencil", "Pastel", "Oil Pastel",
    "Ink (Pen & Ink)", "Ink (Brush)", "Conté Crayon", "Sanguine", "Chalk",
    "Marker", "Crayon", "Silverpoint",

    # Digital Art
    "Digital Painting", "Vector Art", "3D Rendering", "Photobashing", "Matte Painting",
    "Vexel Art", "Pixel Art", "Generative Art", "AI Art",

    # Printmaking
    "Etching", "Engraving", "Lithography", "Woodcut", "Linocut", "Screen Printing",
    "Monotype", "Aquatint", "Drypoint", "Mezzotint",

    # Sculpture & 3D
    "Clay Sculpture", "Bronze Sculpture", "Stone Sculpture", "Wood Sculpture",
    "Metal Sculpture", "Resin Sculpture", "Mixed Media (3D)", "Assemblage (3D)",
    "Installation Art", "Ceramics", "Pottery", "Glass Art", "Paper Mache",
    "Found Object Art", "Kinetic Sculpture",

    # Photography & Film
    "Photography", "Fine Art Photography", "Portrait Photography",
    "Landscape Photography", "Documentary Photography", "Street Photography",
    "Black & White Photography", "Film Photography", "Digital Photography",
    "Cinematography", "Animation", "Stop Motion",

    # Textiles & Fibre Arts
    "Embroidery", "Tapestry", "Weaving", "Knitting", "Crochet", "Felting",
    "Quilting", "Textile Art", "Fibre Sculpture",

    # Mixed Media & Other
    "Mixed Media (2D)", "Collage", "Decoupage", "Assemblage (2D)",
    "Airbrush", "Calligraphy", "Typography", "Gold Leaf", "Silver Leaf",
    "Enamel", "Mosaic", "Stained Glass", "Body Art", "Performance Art"
  ]
}.freeze # Freeze to prevent accidental modification

total_tags_created = 0

TAG_DATA.each do |tag_type, tag_names|
  puts "Seeding #{tag_names.count} '#{tag_type}' tags..."
  tag_names.each do |tag_name|
    # `find_or_create_by!` will find an existing record or create a new one.
    # The `!` will raise an error if creation fails, which is good for debugging.
    Tag.find_or_create_by!(name: tag_name, tag_type: tag_type) do |tag|
      # This block is only executed if a new tag is being created.
      # It allows you to set default attributes if needed, though for name/type it's redundant.
      # For example, if you had a `description` attribute that you wanted to set only on creation.
    end
    total_tags_created += 1
  end
end

puts "--- Tag Seeding Complete! ---"
puts "Total tags in database: #{Tag.count}"
puts "New tags added during this run: #{total_tags_created}"
