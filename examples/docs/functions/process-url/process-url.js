const cloudinary = require("cloudinary").v2;
cloudinary.config({
  cloud_name: "dillonkearns",
  api_key: process.env.CLOUDINARY_KEY,
  api_secret: process.env.CLOUDINARY_SECRET,
});

exports.handler = async function (event, ctx) {
  const pathToScreenshot = event.path.replace(/^.*process-url\//, "");

  try {
    const imageUrl = cloudinary.url(
      `https://res.cloudinary.com/dillonkearns/image/upload/v1621026065/elm-pages/1x1-ff00007f_rd0kpy.png`,
      {
        // resouce_type: "raw"
        sign_url: true,
        // secure: true,
        custom_pre_function: {
          function_type: "remote",
          source: `${process.env.URL}/screenshot/${pathToScreenshot}`,
        },
      }
    );
    return {
      statusCode: 302,
      headers: {
        Location: imageUrl,
      },
      body: "",
    };
  } catch (e) {
    console.log(e);
  }
};