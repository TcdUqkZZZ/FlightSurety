const webpack = require('webpack')
const path = require('path')
const nodeExternals = require('webpack-node-externals')
const StartServerPlugin = require('start-server-nestjs-webpack-plugin')

module.exports = {
    entry: [
        'webpack/hot/poll?1000',
        'regenerator-runtime/runtime.js',
        './src/server/index'
    ],
    watch: true,
    target: 'node',
    externals: [nodeExternals({
        allowlist: ['webpack/hot/poll?1000']
    })],
    module: {
        rules: [{
            test: /\.js?$/,
            use: 'babel-loader',
            exclude: /node_modules/
        }]
    },
    plugins: [
        new StartServerPlugin('server.js'),
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NoEmitOnErrorsPlugin(),
        new webpack.EnvironmentPlugin({
            "process.env": {
                NODE_ENV: 'development'
            }
        }),
    ],
    output: {
        path: path.join(__dirname, 'prod/server'),
        filename: 'server.js'
    }
}