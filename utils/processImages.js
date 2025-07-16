import axios from "axios";
import mime from "mime-types";

export const urlToGenerativePart = async (url) => {
  try {
    const response = await axios.get(url, { responseType: "arraybuffer" });
    const mimeType = response.headers["content-type"] || mime.lookup(url);
    if (!mimeType || !mimeType.startsWith("image/")) {
      console.error("processImages | Unsupported image MIME type:", mimeType);
      return { Error: "Unsupported image MIME type" };
    }
    const base64Data = Buffer.from(response.data, "binary").toString("base64");
    return {
      inlineData: {
        data: base64Data,
        mimeType,
      },
    };
  } catch (error) {
    console.error(
      "processImages | Error fetching image from URL:",
      error.message
    );
    return { Error: "Error fetching image from URL" };
  }
};

export const processImages = async (images) => {
  try {
    const imageParts = await Promise.all(
      images.map(async (img) => await urlToGenerativePart(img))
    );

    return imageParts;
  } catch (error) {
    console.error("processImages | Error:", error);
    return [];
  }
};
