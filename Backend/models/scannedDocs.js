import mongoose from "mongoose"

const ScannedDocSchema = mongoose.Schema({
    user:{
        type:mongoose.Schema.Types.ObjectId,
        ref:"users"
    },
    content:{
        type:String,
        required:true
    },
    date:{
        type:Date,
        default:Date.now
    },
    image:{
        type:String,
    },
    title:{
        type:String,
    },
})

const ScannedDocModel = mongoose.model("ScannedDocs", ScannedDocSchema);
export default ScannedDocModel;