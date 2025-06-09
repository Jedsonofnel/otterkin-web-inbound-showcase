module GeminiSchemas
  ARTIST_DRAFT = {
    introduction: {
      type: "BOOLEAN",
      description: "Set to `true` if the email is an artist's introduction, even if sparse. Only set to `false` if it's clearly not an introduction or is an unrelated query. If `false`, disregard other fields."
    },
    first_name: { type: "STRING" },
    last_name: { type: "STRING" },
    biography: {
      type: "STRING",
      description: "Short artist biography to go at the top of their profile page, in 3rd person."
    },
    location: {
      type: "STRING",
      description: "Area that artist is likely to be based out of"
    },
    tags: {
      type: "OBJECT",
      description: "One word tags to characterise the artist, up to 4 of each please.",
      properties: {
        style_tags: {
          type: "ARRAY",
          items: { type: "STRING" }
        },
        medium_tags: {
          type: "ARRAY",
          items: { type: "STRING" }
        },
        subject_tags: {
          type: "ARRAY",
          items: { type: "STRING" }
        }
      },
      required: [ "style_tags", "medium_tags", "subject_tags" ]
    },
    questions: {
      type: "ARRAY",
      description: "Come up with and answer three insightful questions as if you were the artist, max 200 words per answer.",
      min_items: 3,
      max_items: 3,
      items: {
        type: "OBJECT",
        properties: {
          question: { type: "STRING" },
          answer: { type: "STRING" }
        },
        required: [ "question", "answer" ]
      }
    },
    commission_types: {
      type: "ARRAY",
      description: "Come up with five commission types an artist might offer on their page.  Make sure they feel premium to reflect our business.",
      min_items: 5,
      max_items: 5,
      items: {
        type: "OBJECT",
        description: "A commission type that an artist might offer.  for example a watercolour landscape for 2000 pounds on a 20 by 20 inches canvas.",
        properties: {
          subject: { type: "STRING" },
          medium: { type: "STRING" },
          price: { type: "INTEGER" },
          width: { type: "INTEGER" },
          height: { type: "INTEGER" },
          unit: { type: "STRING", enum: [ "cm", "inches" ] }
        },
        required: [ "subject", "medium", "price", "width", "height", "unit" ]
      }
    }
  }
end
