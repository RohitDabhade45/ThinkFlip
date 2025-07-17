# ThinkFlip

ThinkFlip is an intelligent flashcard generation tool that uses OCR to extract text from books and transforms it into interactive flashcards. The platform helps users memorize content efficiently while maintaining a history of all scanned text, organized into decks.

## Features

- **Text Extraction:** Scan text from books and convert it into digital format.
- **AI-Powered Flashcards & MCQs:** Automatically generate question-answer pairs, multiple-choice questions (MCQs), and flashcards with images from scanned text.
- **Deck Management:** Organize flashcards into decks based on topics or books.
- **User History:** Maintain a history of scanned text and related flashcards.
- **Interactive Learning:** Engage with flashcards in an interactive quiz format.

## Tech Stack

(ThinkFlip is a mobile-only application.)

- **Frontend:** Flutter (for mobile application)
- **Backend:** Node.js with Express
- **Database:** MongoDB (for storing user data and flashcards)
- **AI Integration:** Gemini AI for text processing and flashcard generation

## Installation

### Prerequisites

Ensure you have the following installed:

- Node.js (v16+)

- MongoDB

### Steps

1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-username/thinkflip.git
   ```
2. **Install dependencies:**
   ```sh
   npm install
   ```
3. **Set up environment variables:**
   Create a `.env` file in the root directory and add:
   ```env
   MONGO_URI=your_mongodb_connection_string
   GEMINI_API_KEY=your_gemini_ai_key
   ```
4. **Start the backend server:**
   ```sh
   npm run server
   ```

## Usage

- Scan text using the mobile app.
- The AI processes the text and generates flashcards.
- View and interact with your flashcards within decks.
- Track your learning history.

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to your branch (`git push origin feature-name`).
5. Open a Pull Request.

## Contact

For questions or suggestions, reach out at rohitdabhade\_230369\@aitpune.edu.in .

