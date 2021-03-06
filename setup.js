#!/bin/env node
const fetch = require('node-fetch');
const fs = require('fs');
const YAML = require('yaml');
const path = require('path');

(async () => {
    // generate the op file
    if (process.env.OPS) {
        const res = await Promise.all(process.env.OPS.split(',').map(async user => (await fetch(`https://api.mojang.com/users/profiles/minecraft/${user}`)).json() ));
        const ops = res.map(user => {
            return {
                uuid: [ user.id.slice(0,8), user.id.slice(8,12), user.id.slice(12,16), user.id.slice(16,20), user.id.slice(20) ].join('-'),
                name: user.name,
                level: 4
            }
        });
        await fs.promises.writeFile('/data/ops.json', JSON.stringify(ops), { encoding: 'utf-8' });
    }
    // now install plugins 
    
    try {
        const ymllist = await fs.promises.readFile('/mc/config/plugin-list.yml', 'utf-8');
        const ymlloc = await fs.promises.readFile('/data/plugins/plugin-loc.yml', 'utf-8');
        const loc = YAML.parse(ymlloc) || {};
        const pl = YAML.parse(ymllist) || {};
        await Promise.all(Object.keys(pl).map(p => {
            return (async () => {
                try {
                    if (!loc[p]) loc[p] = { version: false };
                    if (loc[p].version != pl[p].version) {
                        const res = await fetch(pl[p].url);
                        
                        await new Promise((resolve, reject) => {
                            const fileStream = fs.createWriteStream(path.resolve('/data/plugins', `${p}-${pl[p].version}.jar`));
                            res.body.pipe(fileStream);
                            res.body.on("error", (err) => {
                                console.log(`Failed to dowload plugin: ${p}-${pl[p].version}.jar`);
                                fileStream.close();
                                reject(err);
                            });
                            fileStream.on("finish", function() {
                                console.log(`Downloaded plugin: ${p}-${pl[p].version}.jar`);
                                loc[p] = { ...pl[p], path: path.resolve('/data/plugins', `${p}-${pl[p].version}.jar`) };
                                fileStream.close();
                                resolve();
                            });
                        });
                    }
                } catch (error) {
                    console.error(error);
                }
            })();
        }));
        await fs.promises.writeFile('/data/plugins/plugin-loc.yml', '# THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.\n# Generated at ' + new Date().toTimeString() + '\n' + YAML.stringify(loc), 'utf-8');
    } catch (error) {
        console.warn('[WARN] PLUGIN MANAGER ERROR: ', error)
    }
})().catch(console.error);