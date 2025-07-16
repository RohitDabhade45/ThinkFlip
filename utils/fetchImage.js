export const fetchImage = async (query) => {
    const url = `https://www.googleapis.com/customsearch/v1?q=${query}&cx=${process.env.GOOGLE_SEARCH_ENGINE_ID}&searchType=image&key=${process.env.GOOGLE_API_KEY}&num=1`;

    try {
        const response = await fetch(url);
        const data = await response.json();
        if (data.items && data.items.length > 0) {
            return data.items[0].link;
        } else {
            console.log("No image found for:", query);
            return "https://t4.ftcdn.net/jpg/04/00/24/31/360_F_400243185_BOxON3h9avMUX10RsDkt3pJ8iQx72kS3.jpg";
        }
    } catch (error) {
        console.error("Error fetching image for:", query, error);
        return "https://via.placeholder.com/300";
    }
};