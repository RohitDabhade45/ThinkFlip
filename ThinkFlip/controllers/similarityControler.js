import axios from 'axios';
import NLPCloudClient from 'nlpcloud';

const client = new NLPCloudClient({
  model: 'paraphrase-multilingual-mpnet-base-v2',
  token: process.env.NLPCLOUD_API_KEY,
  gpu: false
});

export const textSimilarityNinja = async (req, res) => {
  const { text_1, text_2 } = req.body;

  try {
    const response = await axios.post(
      'https://api.api-ninjas.com/v1/textsimilarity',
      { text_1, text_2 },
      {
        headers: {
          'X-Api-Key': process.env.API_NINJAS_KEY,
        },
      }
    );

    res.status(200).json(response.data);
  } catch (error) {
    console.error('API Error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      message: 'Failed to fetch similarity score',
      error: error.response?.data || error.message,
    });
  }
};

export const textSimilarityNlpCloud = async (req, res) => {
  try {
    const { text1, text2 } = req.body;

    const response = await client.semanticSimilarity({
      sentences: [text1, text2],
    });

    res.json({ similarityScore: response.data });
  } catch (err) {
    res.status(err.response?.status || 500).json({
      error: err.response?.data?.detail || 'Internal Server Error',
    });
  }
};
