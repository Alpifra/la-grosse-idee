const path = require('path');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {

    mode: 'development',
    devtool: 'source-map',
    plugins: [new MiniCssExtractPlugin()],

    entry: './resources/js/app.js',
    output: {
        filename: 'app.js',
        path: __dirname + '/public/assets/',
    },

    module: {
        rules: [{
            test: /\.js$/,
            exclude: /node_modules/,
            use: {
                loader: "babel-loader",
            },
        }, {
            test: /\.s[a|c]ss$/,
                exclude: /node_modules/,
                use: [MiniCssExtractPlugin.loader, "css-loader", "sass-loader"],
        }]
    },
}