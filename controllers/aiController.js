import { textOnly } from "../utils/textOnly.js";
import { textAndImage } from "../utils/textAndImage.js";
import { fetchImage } from "../utils/fetchImage.js";
import axios from 'axios';

const preprocess = (result) => {
  try {
    const match = result.match(/\[.*?\]/s);
    if (!match) throw new Error("No JSON array found in the result");
    return JSON.parse(match[0]);
  } catch (error) {
    console.error("Invalid JSON response from the bot", error);
    return null;
  }
};

const calculateSimilarity = async (text1, text2) => {
  try {
    const response = await axios.post(
      'https://api.api-ninjas.com/v1/textsimilarity',
      { text_1: text1, text_2: text2 },
      {
        headers: {
          'X-Api-Key': process.env.API_NINJAS_KEY,
        },
      }
    );
    return Math.round(response.data.similarity * 100);
  } catch (error) {
    console.error('API Ninjas Error:', error);
    return 0;
  }
};

const processFlashcards = async (flashcards, originalText) => {
  return Promise.all(
    flashcards.map(async (flashcard) => {
      const [imageUrl, accuracy] = await Promise.all([
        fetchImage(flashcard.title),
        calculateSimilarity(originalText, flashcard.description)
      ]);
      return { ...flashcard, imageUrl, accuracy };
    })
  );
};

export const aiController = async (req, res) => {
  const modelType = req.body.modelType;
  const number = req.body.number ? req.body.number : null;
  const originalText = req.body.prompt;

  if (modelType === "text_only") {
    const botReply = await textOnly(`${originalText.replace(/(\r\n|\n|\r)/g, " ")} \n  Summarize the given text to generate ${number!=null ? number : 'as many as possible'} flashcards based strictly on its content as a JSON array. Each flashcard should have the following structure:
      {title: "Short title of the flashcard",description: "5-sentence description of the topic"}.Ensure the output is a valid JSON array without use of /n.`);
    
    try {
      let flashcards = preprocess(botReply.result);
      if (!flashcards) throw new Error("Failed to parse flashcards");

      // Process flashcards - add images and calculate accuracy
      flashcards = await processFlashcards(flashcards, originalText);
      
      res.status(200).json({ result: flashcards });
    } catch (error) {
      res.status(500).json({ error: "Invalid JSON response from the bot", result: botReply.result });
    }

  } else if (modelType === "text_and_image") {
    const botReply = await textAndImage(`Summarize the given image to generate ${number!=null ? number:'as many as possible'} flashcards based strictly on its content as a JSON array. Each flashcard should have the following structure:{title:Short title of the flashcard,description: 5-sentence description of the topic}.Ensure the JSON output is properly formatted, valid, and does not include newline characters (\n).`, req.body.imageParts);

    try {
      let flashcards = preprocess(botReply.result);
      if (!flashcards) throw new Error("Failed to parse flashcards");

      // Process flashcards - add images and calculate accuracy
      flashcards = await processFlashcards(flashcards, originalText);

      res.status(200).json({ result: flashcards });
    } catch (error) {
      res.status(500).json({ error: "Invalid JSON response from the bot", result: botReply.result });
    }
  } else {
    res.status(404).json({ result: "Invalid Model Selected" });
  }
};
