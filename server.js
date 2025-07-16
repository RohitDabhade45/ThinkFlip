import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import AuthRouter from './routes/authRouter.js';
import GeminiRouter from './routes/geminiRouter.js';
import HistoryRouter from './routes/historyRouter.js';
import SimilarityRouter from './routes/similarityRoutes.js';


const app = express();
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "DELETE", "PUT", "PATCH", "OPTIONS"],
    credentials: true,
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));

import dotenv from 'dotenv';
dotenv.config();

import './models/db.js';


const PORT = process.env.PORT;

app.get('/',(req,res)=>{
  res.send("ThinkFlip Backend");
})

app.use('/gemini', GeminiRouter);
app.use('/auth', AuthRouter);
app.use('/history', HistoryRouter);
app.use('/accuracy', SimilarityRouter);



app.listen(PORT, () => {
  console.log("Gemini AI Server is listening on port number", PORT);
});


