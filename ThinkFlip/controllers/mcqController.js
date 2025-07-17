import { textOnly } from "../utils/textOnly.js";
import { textAndImage } from "../utils/textAndImage.js";

const preprocess = (result) => {
  try {
    let cleanedResult = result.replace(/```json\s*|\s*```/g, "").trim();
    const match = cleanedResult.match(/\[.*\]/s);
    if (!match) throw new Error("No JSON array found in the result");
    return JSON.parse(match[0]);
  } catch (error) {
    console.error("Invalid JSON response from the bot", error, "result:", result);
    return null;
  }
};



export const mcqController = async (req, res) => {
  const modelType = req.body.modelType;
  const number = req.body.number? req.body.number : null;

  if (modelType === "text_only") {
    const botReply = await textOnly(`${req.body.prompt.replace(/(\r\n|\n|\r)/g, " ")} \n  From the given text to generate ${number!=null ? number : 'as many as possible'} MCQ as a JSON array. Each MCQ should have the following structure:
      {question: "question",options:[option1,option2,option3,option4],correctOption:"option",explanation:"explanation of the question"}. Ensure the output is a valid JSON array without use of /n.`);
    try {
      let mcqs = preprocess(botReply.result);
      if (!mcqs) throw new Error("Failed to parse mcq");
      res.status(200).json({ result: mcqs });
    } catch (error) {
      res.status(500).json({ error: "Invalid JSON response from the bot", result: botReply.result });
    }

  } else if (modelType === "text_and_image") {
    const botReply = await textAndImage(`From the given image to generate ${number!=null ? number :'as many as possible'}MCQ as a JSON array. Each MCQ should have the following structure:{question: "question",options:[option1,option2,option3,option4],correctOption:"option",explanation:"explanation of the question"}.Ensure the output is a valid JSON array without use of /n.`, req.body.imageParts);

    try {
      let mcqs = preprocess(botReply.result);
      if (!mcqs) throw new Error("Failed to parse mcqs");
      res.status(200).json({ result: mcqs });
    } catch (error) {
      res.status(500).json({ error: "Invalid JSON response from the bot", result: botReply.result });
    }
  } else {
    res.status(404).json({ result: "Invalid Model Selected" });
  }
};
