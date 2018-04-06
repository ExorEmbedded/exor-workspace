// jmuGenHistory.js
//
// A binary image and commit history generation tool
//
// See 'jmuGenHistory.js help' for usage info.
//
// Samples:
//   - Generate info for single release for specific platform (on unstable branch)
//	sudo node ./utils/jmuGenHistory.js gen -u -s 1.999.292 -p UN67_WU16 -n 1		
//   - Merge info into new history file (on unstable branch)
//	sudo node ./utils/jmuGenHistory.js merge -u
// 
// Notes:
//   - async calls not used for simplicity since this is just a script
//    (also, parallelism would require lots of disk space for untarred images)
//
var m_exec = require('execSync');
var m_fs = require('fs');
var m_getopt = require('node-getopt');
var m_merge = require('deepmerge');
var m_path = require('path');
var m_util = require('util');

var getopt = new m_getopt([
        [ 'r', '=', 'repository source base directory (production default)' ],
        [ 'd', '=', 'delivering directory containing images (production default)' ],
        [ 'o', '=', 'OS type: linux (default)|android' ],
        [ 'u', '',  'unstable build (stable is default)' ],
        [ 'p', '=', 'specify a comma-separated list of platforms - generate all if unspecified (e.g. UN60_HSXX,UN66_CA16, UN67_WU16)' ],
        [ 's', '=', 'COMMAND=gen: start release for history generation' ],
        [ 'n', '=', 'COMMAND=gen: number of diffs to generate (requires n+1 releases)' ],
        [ 'v', '',  'increase verbosity' ]
]);

// default values for arguments retrieved via getopt()
var defaults = {
    d : '/home/autosvn/work/delivering',
    o : 'linux',
    n : 1,  // by default we only generate diffs to previous
    v : false
};

// command-line args will popule this
var opts = {};

// other internal variables (fixed)
var vars = {
    version :       '0.0.13',
    prog :          m_path.basename(process.argv[1]),
    branch :        '',  // defined later after processing '-u'
    platforms : [
        // uniquely identified by cpu+carrier
        { cpu : 'UN60', carrier : 'HSXX' },
        { cpu : 'UN61', carrier : 'PLCM' },
        { cpu : 'UN63', carrier : 'BE15' },
        { cpu : 'UN64', carrier : 'HSXX' },
        { cpu : 'UN65', carrier : 'HSXX' },
        { cpu : 'UN66', carrier : 'CA16' },
        { cpu : 'UN67', carrier : 'WU16' },
        { cpu : 'UN68', carrier : 'WU16' },
        { cpu : 'UN69', carrier : 'AU16' },
        { cpu : 'UN70', carrier : 'HS07' },
        { cpu : 'UN71', carrier : 'JSXX' },
        { cpu : 'UN72', carrier : 'NA16' },
        { cpu : 'UN73', carrier : 'BE15' }
    ],
    image_types : {
        linux :     [ 'mainos', 'configos' ],
        android :   [ 'system' ]
    },
    repos : {
        linux : [
          // 'name' must be UNIQUE      // 'path' to repo (relative)    //  unfuddle repo 'id'
                                        // same as name if undefined
            { name : 'linux-bsp',           path : 'bsp',                   id: 148 },
            { name : 'yocto-poky',          path : 'poky',                  id: 154 },
            { name : 'meta-openembedded',                                   id: 152 },
            { name : 'meta-exorint',                                        id: 147 },
            { name : 'meta-exorint-enterprise',                             id: 161 },
            { name : 'meta-branding-exorint',                               id: 156 },
            { name : 'usbupdater',                                          id: 171 }
        ],
        android : [
            { name : 'aosp-ext',            path : 'aosptool/externals',    id: 179 },
            { name : 'aosp-kernel',         path : 'aosp/kernel',           id: 184 },
            { name : 'aosp-device',         path : 'aosp/device/ti/us01',   id: 177 }
        ],
    },
    blacklist : {
        linux : [
            '/boot/version',
            '/etc/migrations/version',
            '/etc/version',
            '/etc/timestamp',
            '/etc/passwd',
            '/etc/group',
            '/etc/shadow',
            '/etc/gshadow',
            '/var/lib/rpm',
            '/var/lib/opkg/alternatives',
            '/var/cache/ldconfig/aux-cache',
            '/var/cache/fontconfig',
            '/etc/gconf/gconf.xml.defaults/schemas/system/gstreamer/0.10/default/%gconf.xml',
            '/etc/gconf/gconf.xml.defaults/system/gstreamer/0.10/default/%gconf.xml'
        ],
        android : []
    },
    diffs : {
        changed_size : 16, // by how many bytes files should differ before they are marked as changed
        modified_toomany : 200 // how many modified files are allowed before showing "Too Many Changes!"
    },
    max_skip : 50 // maximum jump between consecutive versions
};
vars.tmpdir = m_path.join('/tmp', m_util.format('%s-%s', vars.prog, process.pid));

function info (msg)
{
    console.log('# ' + msg);
};

function debug (msg)
{
    if (opts.v)
        console.log('# ' + msg);
};

function warning (msg)
{
    console.warn('# WARNING: ' + msg);
};

function error (msg)
{
    console.error('# ERROR: ' + msg);
    cleanup();
    process.exit(1);
};

// XX.YYY.ZZZ version format assumed
function decVersion (v)
{
    if (v === '0.0.0')
        return null;

    var vs = v.split('.');

    for (var i = (vs.length - 1); i >= 0; i--)
    {
        vp = vs[i];

        if (vp == 0)
        {
            vs[i] = '999';
        }
        else if (vp > 0)
        {
            vs[i]--;
            break;
        }
    }

    return vs.join('.');
};

function get_file_name (cpu, carrier, type, v)
{
    return m_util.format('%s-%s-%s-%s',
            cpu.toLowerCase(),
            carrier.toLowerCase(),
            type,
            v);
};

function get_image_dir (platform, type)
{
    if (opts.o === 'linux' && (platform.paths == null || platform.paths.linux == null))
        var dir = m_path.join(opts.d, platform.cpu + '_' + platform.carrier, 'linux-' + vars.branch, 'BSP');
    else if (opts.o === 'android' && (platform.paths == null || platform.paths.android == null))
        var dir = m_path.join(opts.d, platform.cpu + '_' + platform.carrier, 'android');
    else
        var dir = platform.paths[opts.o];

    if (vars.image_types[opts.o].length > 1)
        return m_path.join(dir, type);
    else  // when there is only one image type like on android, there's no directory suffix
        return dir;
};

function get_image_path (cpu, carrier, path, type, v)
{
    var fn = get_file_name(cpu, carrier, type, v);

    if (opts.u)
        fn += '-u';

    // only Linux images have 'rootfs' suffix
    if (opts.o === 'linux')
        fn += '.rootfs';
    fn += '.tar.gz';

    return m_path.join(path, fn);
};

function get_image_path_broken (cpu, carrier, path, type, v)
{
    return get_image_path(cpu, carrier, path, type, v) + '-broken';
};

function get_info_path (cpu, carrier, path, type, v)
{
    var fn = get_file_name(cpu, carrier, type, v) + '.info.json';

    return m_path.join(path, fn);
};

function file_exists (path)
{
    debug('file_exists? ' + path);

    try {
        m_fs.statSync(path);  // m_fs.exists* are deprecated
        return true;
    } catch (e) {
        return false;
    }
};

function file_is_link (path)
{
    var lstat = m_fs.lstatSync(path);

    if (lstat && lstat.isSymbolicLink())
        return true;

    return false;
};

// Return whether file size from 'path1' to 'path2' has changed more than 'howmuch'
function file_size_changed (path1, path2, howmuch)
{
    if (file_is_link(path1) || file_is_link(path2))
        return true;

    var stat1 = m_fs.statSync(path1);
    var stat2 = m_fs.statSync(path2);
    var size_diff = Math.abs(stat2.size - stat1.size);

    //debug(m_util.format('file_size_changed %s => %s = %d', path1, path2, size_diff));

    return (size_diff > howmuch);
};
    
function image_exists (cpu, carrier, path, type, v)
{
    return (file_exists(get_image_path(cpu, carrier, path, type, v)) ||
            file_exists(get_image_path_broken(cpu, carrier, path, type, v)))
};

function image_previous (cpu, carrier, path, type, v)
{
    var vp = v;
    var r = 0;

    do {
        if ((vp = decVersion(vp)) == null)
            return null;

        if (image_exists(cpu, carrier, path, type, vp))
            return vp;

        r++;
    } while (r < vars.max_skip);

    return null;
};

function run (cmd)
{
    debug('run cmd: ' + cmd);

    return m_exec.run(cmd);
};

function exec (cmd)
{
    debug('exec cmd: ' + cmd);

    return m_exec.exec(cmd);
};

function file_blacklisted (path)
{
    var blacklist = vars.blacklist[opts.o];

    for (var i in blacklist)
        if (path.match(new RegExp(m_util.format('^%s', blacklist[i]))))
            return true;

    return false;
};

function do_gen_info (cpu, carrier, path, vp, type, v)
{
    var json = {
        image :         get_file_name(cpu, carrier, type, v),
        created :       new Date().toISOString(),
        version :       vars.version
    };

    var info_path = get_info_path(cpu, carrier, path, type, v);
    var info_path_tmp = info_path + '.tmp';

    debug('info_path: ' + info_path);

    if (vp == null)
    {
        info(m_util.format('No diffs for v%s', v));
        m_fs.writeFileSync(info_path_tmp, JSON.stringify(json, null, 4));
        m_fs.renameSync(info_path_tmp, info_path);
        return;
    }
    json.prev_image = get_file_name(cpu, carrier, type, vp);

    info(m_util.format('Generating diffs of v%s from previous v%s', v, vp));

    var prev_file_path = get_image_path(cpu, carrier, path, type, vp);
    if (!file_exists(prev_file_path))
        prev_file_path = get_image_path_broken(cpu, carrier, path, type, vp);

    var file_path = get_image_path(cpu, carrier, path, type, v);
    if (!file_exists(file_path))
    {
        file_path = get_image_path_broken(cpu, carrier, path, type, v);
        json.state = 'broken';
    }

    var prev_base = 'image-v1';
    var base = 'image-v2';
    var prev_dir_path = m_path.join(vars.tmpdir, prev_base);
    var dir_path = m_path.join(vars.tmpdir, base);

    var res;

    if (run(m_util.format('rm -rf %s', vars.tmpdir)) ||
            run(m_util.format('mkdir -p %s && tar -xzf %s -C %s', prev_dir_path, prev_file_path, prev_dir_path)) ||
            run(m_util.format('mkdir -p %s && tar -xzf %s -C %s', dir_path, file_path, dir_path)))
        error('run() exited with error!');

    res = exec(m_util.format('cd %s && diff --no-dereference -urq %s %s', vars.tmpdir, prev_base, base));

    var diffs = {};
    var lines = res.stdout.split('\n');

    for (var i in lines)
    {
        var line = lines[i];
        if (line === '')
            continue;

        //debug('line: ' + line);

        var match;
        // files only in current version => added (+)
        if (match = line.match(new RegExp(m_util.format('^Only in %s/?(.*): (.*)', base))))
        {
            if (diffs.added == null)
                diffs.added = [];
            diffs.added.push('/' + m_path.join(match[1], match[2]));
        }

        // files only in previous release => removed (-)
        else if (match = line.match(new RegExp(m_util.format('^Only in %s/?(.*): (.*)', prev_base))))
        {
            if (diffs.removed == null)
                diffs.removed = [];
            diffs.removed.push('/' + m_path.join(match[1], match[2]));
        }

        // files differ - see if changed or modified
        else if (match = line.match(new RegExp(m_util.format('^(Files|Symbolic links) %s/?(.*) and %s/?(.*) differ', prev_base, base))))
        {
            if (match[2] !== match[3])
            {
                warning(m_util.format('Expected match: %s === %s', match[2], match[3]));
                continue;
            }

            if (file_blacklisted('/' + match[2]))
                continue;

            var changed = file_size_changed(m_path.join(prev_dir_path, match[2]), m_path.join(dir_path, match[3]),
                    vars.diffs.changed_size);

            if (changed)
            {
                if (diffs.changed == null)
                    diffs.changed = [];
                diffs.changed.push('/' + match[2]);
            }
            else
            {
                if (diffs.modified == null)
                    diffs.modified = [];
                diffs.modified.push('/' + match[2]);
            }
        }
        else if (match = line.match(new RegExp(m_util.format('^File %s/?(.*) is a (character special file|block special file|fifo)', prev_base))))
            ;  // ignore
        else 
            warning('no matching regex for line: ' + line);
    }

    if (diffs.modified && (diffs.modified.length > vars.diffs.modified_toomany))
        json.diffs = { toomany: true };
    else
        json.diffs = diffs;
    debug('json: ' + JSON.stringify(json));

    m_fs.writeFileSync(info_path_tmp, JSON.stringify(json, null, 4));
    m_fs.renameSync(info_path_tmp, info_path);
};

function do_gen ()
{
    if (opts.s == null)
        error('Start release must be specified for COMMAND=gen!');

    var types = vars.image_types[opts.o];

    var chosenPlatforms = (opts.p == null ? [] : opts.p.split(','));
    info(m_util.format('Chosen platforms: %s', JSON.stringify(chosenPlatforms)));
    
    for (var i in types)
    {
        var type = types[i];

        for (var j in vars.platforms)
        {
            var p = vars.platforms[j];

            var cpu = p['cpu'];
            var carrier = p['carrier'];
            var pName = cpu + '_' + carrier;

            if (chosenPlatforms.length > 0 && chosenPlatforms.indexOf(pName) == -1)
            {
                debug(m_util.format('Skipping unchosen platform: \'%s\'', pName));
                continue;
            }

            info(m_util.format('Generating history for last \'%d\' release(s) of \'%s\' from version \'%s\'.',
                opts.n, type, opts.s));

            var path = get_image_dir(p, type);

            info('');
            info(m_util.format('Entering path: \'%s\'', path));

            // initial version == start version
            var v = opts.s;

            if (!image_exists(cpu, carrier, path, type, v))
            {
                info('No initial version - giving up on current path!');
                continue;
            }

            for (var k = 0; k < opts.n; k++)
            {
                debug('k: ' + (k+1));

                var vp = image_previous(cpu, carrier, path, type, v);

                debug('v: ' + v);
                debug('vp: ' + vp);

                do_gen_info(cpu, carrier, path, vp, type, v);

                if (vp == null)
                {
                    info(m_util.format('No version detected prior to v%s', v));
                    break;
                }

                v = vp;
            }
        }
    }
};

// Sample merged info format:
//  {
//      [..]
//      "releases" : {
//          "1.2.3" : {
//              "images" : {
//                  "mainos" : {
//                      "platforms" : {
//                          "UN60" : {
//                              diffs : [
//                                   '/etc/exorint.funcs',
//                                   '/usr/bin/EPAD'
//                              ]
//                          }
//                      }
//                  },
//                  "configos" : { [..] }
//              }
//          }
//      }
//  }
function do_merge_image (dir, image, jres) 
{
    info('Merging info: ' + image);

    var s = m_fs.readFileSync(m_path.join(dir, image + '.info.json'));
    //debug('s: ' + s);

    var json = JSON.parse(s);

    if (json.image !== image)
        error('Failed consistency check: (bad \'image\' key)!');

    var split = image.split('-');
    debug('split: ' + split);

    var cpu = split[0];
    var carrier = split[1];
    var type = split[2];
    var v = split[3];
    var platform_id = cpu.toUpperCase() + '_' + carrier.toUpperCase();

    var image_info = {};
    image_info.diffs = json.diffs;
    if (json.state)
        image_info.state = json.state;

    if (jres.releases[v] == null)
        jres.releases[v] = {};

    if (jres.releases[v].images == null)
        jres.releases[v].images = {};

    if (jres.releases[v].images[type] == null)
        jres.releases[v].images[type] = {};

    if (jres.releases[v].images[type].platforms == null)
        jres.releases[v].images[type].platforms = {};

    jres.releases[v].images[type].platforms[platform_id] = image_info;
};

function sort_version_asc (a, b)
{
    if (a === b)
        return 0;

    var aa = a.split('.').map(Number);
    var ba = b.split('.').map(Number);

    if (aa[0] > ba[0])
        return 1;
    else if (aa[0] == ba[0])
    {   
        if (aa[1] > ba[1])
            return 1;
        else if (aa[1] == ba[1])
        {   
            if (aa[2] > ba[2])
                return 1;
            else if (aa[2] == ba[2])
                return 0;
        }
    }

    return -1;
};

function sort_version_dsc (a, b)
{
    return sort_version_asc(b, a);
};

function do_merge_commits (jres, prev_ver, ver)
{
    info(m_util.format('Merging commits from \'v%s\' to \'v%s\'', prev_ver, ver));

    var commits = '';

    var repos = vars.repos[opts.o];

    for (var i in repos)
    {
        var repo_name = repos[i].name;
        var repo_path = (repos[i].path ? repos[i].path : repo_name);
        var repo_dir = m_path.join(opts.r, repo_path);

        if (!file_exists(repo_dir))
        {
            warning('Could not find repo dir: ' + repo_dir);
            continue;
        }

        var res;

        res = exec(m_util.format('cd %s && git rev-parse %s%s', repo_dir, vars.tag_prefix, prev_ver));
        var prev_rc = res.code;

        res = exec(m_util.format('cd %s && git rev-parse %s%s', repo_dir, vars.tag_prefix, ver));
        var rc = res.code;

        if (prev_rc && rc)
        {
            warning(m_util.format('No valid tags found in %s', repo_dir));
            continue;
        }

        if (prev_ver == -1 || prev_rc)
        {
            warning('Not generating diff for unknown previous version');
            continue;

            // history of first release will include all previous commits
            //res = exec(m_util.format('cd %s && git log --pretty=oneline --abbrev-commit %s%s',
            //        repo_dir, vars.tag_prefix, ver));
        }
        else
            res = exec(m_util.format('cd %s && git log --pretty=oneline --abbrev-commit %s%s..%s%s' +
                                     ' | { grep -v "Autosvn: Incremented build number" || true; }',
                    repo_dir, vars.tag_prefix, prev_ver, vars.tag_prefix, ver));

        if (res.code)
        {
            warning(m_util.format('Failed getting logs for %s', repo_dir));
            continue;
        }

        if (res.stdout === '')
            continue;

        var newarray = [];
        var lines = res.stdout.split('\n').map(function(line) {
            if (line === '')
                return;

            if (jres.releases[ver].commits == null)
                jres.releases[ver].commits = [];

            jres.releases[ver].commits.push(line.replace(/^/,
                    m_util.format('%s:%s:', repo_name_to_id(repo_name), repo_name)));
        });
    }
};

function do_merge_info () 
{
    info('Merging history');

    var platforms = [];

    for (var i in vars.platforms)
        platforms.push(vars.platforms[i].cpu + '_' + vars.platforms[i].carrier);

    var jres = {
        created :       new Date().toISOString(),
        version :       vars.version,
        platforms :     platforms,
        releases :      {}
    };

    debug('platforms: ' + JSON.stringify(vars.platforms));

    var types = vars.image_types[opts.o];

    for (var i in types)
    {
        var type = types[i];

        for (var j in vars.platforms)
        {
            var p = vars.platforms[j];
            var dir = get_image_dir(p, type);
            var files = [];
    
            info('Entering path: ' + dir);
    
            try {
                files = m_fs.readdirSync(dir);
            } catch (e) {
                warning('Image dir not found: ' + dir);
                continue;
            }
            debug('files: ' + JSON.stringify(files));
    
            for (var k in files)
            {
                var file = files[k];
                debug('file: ' + file);
    
                var re = /(.*)\.info\.json/;
                var match = file.match(re);
                if (match == null) 
                    continue;
    
                var image = match[1];
    
                do_merge_image(dir, image, jres);
            }
        }
    }

    var keys = Object.keys(jres.releases);
    debug('keys: ' + JSON.stringify(keys));

    if (keys.length < 2)
        error('At least 2 versions required for commit history!');

    var sorted_keys = keys.sort(sort_version_asc);
    debug('sorted keys: ' + JSON.stringify(sorted_keys));

    /* Inclusion of full history log of first version made output files too large
       simply not generating it will result in a N/A in HTML result

    var prev_ver = -1;
    var ver = sorted_keys[0];

    do_merge_commits(jres, prev_ver, ver);
    */

    for (var i = 1; i < sorted_keys.length; i++)
    {
        prev_ver = sorted_keys[i-1];
        ver = sorted_keys[i];

        do_merge_commits(jres, prev_ver, ver);
    }

    debug('jres: ' + JSON.stringify(jres));

    info(m_util.format('Outputting history to \'%s\'', vars.history_file_json));

    var file_tmp = vars.history_file_json + '.tmp';
    m_fs.writeFileSync(file_tmp, JSON.stringify(jres, null, 4));
    m_fs.renameSync(file_tmp, vars.history_file_json);

    return jres;
};

function repo_name_to_id (name)
{
    var repos = vars.repos[opts.o];

    for (var i in repos)
        if (repos[i].name === name)
            return repos[i].id;

    return -1;
};

function do_merge ()
{
    var jres = do_merge_info();
    var blacklist = vars.blacklist[opts.o];

    var title = 'BSP Release History';

    //
    // html headers and CSS
    //
    var html = '';
    html += '<html>\n';
    html += '<head>\n';
    html += m_util.format('<title>%s</title>\n', title);
    html += '<style type="text/css">\n';
    html += '<!--\n';
    html += 'table { word-wrap: break-word; border: 1px solid #999; border-collapse: collapse; }\n';
    html += 'table.framed th { word-wrap: break-word; border: 1px solid #999; }\n';
    html += 'table.framed td { word-wrap: break-word; border: 1px solid #999; }\n';
    html += '-->\n';
    html += '</style>\n'
    html += '</head>\n'
    html += '<body>\n'
    html += m_util.format('<h1>%s</h1>\n', title);

    //
    // info tables
    //
    html += '<table style="border:0;">\n'
    html += m_util.format('<tr><td><b>OS</b></td><td style="padding-left: 10px">%s</td></tr>\n', opts.o);
    html += m_util.format('<tr><td><b>Branch</b></td><td style="padding-left: 10px">%s</td></tr>\n', vars.branch);
    html += m_util.format('<tr><td><b>Generated By</b></td><td style="padding-left: 10px">%s v%s</td></tr>\n', vars.prog, jres.version);
    html += m_util.format('<tr><td><b>Creation Date</b></td><td style="padding-left: 10px">%s (UTC)</td></tr>\n', jres.created);
    html += '</table>';
    html += '<table style="border:0; margin-top: 20px">\n'
    if (blacklist.length > 0)
    {
        html += '<tr>\n';
        html += '<td style="padding-right: 10px"><b><font color="red">WARNING!!!</font><br>Blacklist Applied</b></td><td style="border: 1px solid #999; padding-left: 5px">';
        for (var i in blacklist)        
            html += blacklist[i] + '<br>';
        html += '</td>';
        html += '</tr>\n';
    }
    html += '</table>\n'
    html += '<table style="border:0; margin-top: 20px">\n'
    html += '<tr>\n';
    html += '<td style="padding-right: 10px"><b>Diff Legend</b></td><td style="border: 1px solid #999; padding-left: 5px">';
    html += '<tt>+</tt> file has been added in current version<br>';
    html += '<tt>-</tt> file has been removed in current version<br>';
    html += m_util.format('<tt>!</tt> file has changed significantly (size changed more than %d bytes)<br>',
            vars.diffs.changed_size);
    html += m_util.format('<tt>~</tt> file has been slightly modified (size changed by %s or less bytes)<br>',
            vars.diffs.changed_size);
    html += '</td>';
    html += '</tr>\n';
    html += '</table>\n'

    //
    // main table headers
    //
    html += '<table class="framed" style="margin-top: 20px">\n';

    var releases = jres.releases;
    var version_keys = Object.keys(jres.releases);
    var sorted_version_keys = version_keys.sort(sort_version_dsc);
    var sorted_platforms = jres.platforms.sort();
    var types = vars.image_types[opts.o];

    html += '<tr>'
    html += '<th colspan="2">Image Type</th>'
    for (var i in types)
        html += m_util.format('<th colspan="%d" style="color:green; font-size: 24px; border: 2px solid grey;">%s</th>', sorted_platforms.length * 2, types[i]);
    html += '</tr>'

    html += '<tr>'
    html += '<th rowspan="2" class="framed" style="text-align: center;">BSP</th>\n';
    html += '<th rowspan="2" class="framed" style="">Commits</th>\n';
    for (var i in types)
        for (var j in sorted_platforms)
            html += m_util.format('<th colspan="2" style="border-bottom: 1px solid #ddd; font-size: 24px">%s</th>', sorted_platforms[j]);
    html += '</tr>\n';

    html += '<tr>\n';
    for (var i in types)
        for (var j in sorted_platforms)
        {
            html += '<th style="border-right: 1px solid #ddd">Affected</th>'
            html += '<th style="text-align: center">Diffs</th>'
        }
    html += '</tr>\n';

    for (var i in sorted_version_keys) 
    {
        //
        // main table content: commits
        //
        var v = sorted_version_keys[i];

        html += '<tr>';

        html += m_util.format('<td class="framed" style="text-align:center; min-width: 60px">%s</td>', v);
        html += '<td class="framed" style="min-width: 350px; padding-left: 5px">';
        html += '<div style="max-height: 350px; overflow-y: scroll">';

        if (releases[v].commits == null)
            html += '<p style="text-align: center"><i>N/A</i><p>';
        else if (releases[v].commits.length == 0)
            html += '<p style="text-align: center"><i>No Commits</i><p>';
        else
            for (var j in releases[v].commits)
            {
                // reformat a little so there is a newline after repo:hash
                var commit = releases[v].commits[j];

                //                         id   : name  : hash
                html += commit.replace(/^([^:]*):([^:]*):([^ ]*)\ /,
                        '<a href="https://exorint.unfuddle.com/a#/repositories/$1/commit?commit=$3" ' +
                            'target="_blank">$2:$3</a><br><i>') + 
                        '</i><br><br>';
            }
        html += '</div>';
        html += '</td>';

        //
        // main table content: diffs
        //
        for (var j in types)
        {
            var type = types[j];

            for (var k in sorted_platforms)
            {
                var image = releases[v].images[type];

                // no release for this image type
                if (image == null)
                {
                    html += '<td colspan="2" style="text-align: center"><i>N/A</i></td>';
                    continue;
                }

                var p = sorted_platforms[k];
                var platform = image.platforms[p];

                // no build for this platform
                if (platform == null || platform.diffs == null)
                {
                    html += '<td colspan="2" style="text-align: center"><i>N/A</i></td>';
                    continue;
                }

                // no diffs => not affected
                if (Object.keys(platform.diffs).length == 0)
                {
                    html += '<td style="min-width: 60px; text-align: center; border-right: 1px solid #ddd">O</td>';
                    html += '<td style="max-width: 250px; max-width: 250px; text-align: center"><i>No Binary Diffs</i></td>';
                }
                // don't show diffs if there are too many (could be from-scratch build)
                else if (platform.diffs.toomany || (platform.diffs.modified && platform.diffs.modified.length > vars.diffs.modified_toomany))
                {
                    html += '<td style="min-width: 60px; text-align: center; border-right: 1px solid #ddd">X</td>';
                    html += '<td style="max-width: 250px; max-width: 250px; text-align: center"><i>Too Many Diffs!</i></td>';
                }
                // diffs => affected
                else
                {
                    html += '<td style="min-width: 60px; text-align: center; border-right: 1px solid #ddd">X';
                    if (platform.state)
                        html += m_util.format('<br><font color="red">%s</font>', platform.state.toUpperCase());
                    html += '</td>';
                    html += '<td style="min-width: 200px; max-width: 350px; padding-left: 5px">';
                    html += '<div style="max-height: 350px; overflow-y: scroll">';
                    for (var k in platform.diffs.added)
                        html += m_util.format('<tt>+</tt> %s<br>', platform.diffs.added[k]);
                    for (var k in platform.diffs.removed)
                        html += m_util.format('<tt>-</tt> %s<br>', platform.diffs.removed[k]);
                    for (var k in platform.diffs.changed)
                        html += m_util.format('<tt>!</tt> %s<br>', platform.diffs.changed[k]);
                    for (var k in platform.diffs.modified)
                        html += m_util.format('<tt>~</tt> %s<br>', platform.diffs.modified[k]);
                    html += '</div>';
                    html += '</td>';
                }
            }
        }

        html += '</div>\n';
        html += '</tr>\n';
    }

    html += '</table>\n';
    html += '</body>\n'
    html += '</html>\n'

    info(m_util.format('Outputting history to \'%s\'', vars.history_file_html));

    var tmp_file = vars.history_file_html + '.tmp';
    m_fs.writeFileSync(tmp_file, html);
    if (m_fs.existsSync(vars.history_file_html))
        m_fs.renameSync(vars.history_file_html, vars.history_file_html + '.prev');
    m_fs.renameSync(tmp_file, vars.history_file_html);
};

function cleanup ()
{
    debug('Cleaning up');

    exec(m_util.format('[ -e %s ] && rm -rf %s', vars.tmpdir, vars.tmpdir));
};

function init ()
{
    // last resort exception handler
    process.on('uncaughtException', function(err) {
        error('Caught exception: ' + err);
    });

    // setup signal handlers
    process.on('SIGINT', function() {
        debug('Caught SIGINT');
        cleanup();
    });
    process.on('SIGTERM', function() {
        debug('Caught SIGTERM');
        cleanup();
    });
};

function main ()
{
    info(m_util.format('Running %s v%s', vars.prog, vars.version));

    init();

    //info('opts: ' + JSON.stringify(opts));
    getopt.setHelp(
      "Usage: node " + vars.prog + " COMMAND [OPTIONS]\n" +
      "\n" + 
      ", where COMMAND can be on of:\n" +
      "   help               this help\n" +
      "   gen                generate history (.json) for last N versions as specified by -n\n" +
      "   merge              merge all detected change files into a single file (.html)\n" +
      "\n" +
      ", and OPTIONS are as follows:\n" +
      "[[OPTIONS]]\n"
    );
    var opt = getopt.parseSystem();

    if (opt.argv.length !== 1 && Object.keys(opt.options).length === 0)
    {
        getopt.showHelp();
        process.exit(1)
    }
    debug('defaults: ' + JSON.stringify(defaults));
    debug('opt.options: ' + JSON.stringify(opt.options));

    // consistency checks
    if (opt.options.o)
        switch (opt.options.o)
        {
            case 'linux':
            case 'android':
                break;
            default:
                error(m_util.format('Invalid OS type: \'%s\'!', opt.options.o));
        }

    opts = m_merge(defaults, opt.options);

    // variable post-processing
    if (opts.r == null)
    {
        if (opts.o === 'android')
            opts.r = '/home/autosvn/android';
        else
            opts.r = m_path.join('/home/autosvn/work', (opts.u ? 'unstable' : 'stable'), 'git');
    }
    debug('opts: ' + JSON.stringify(opts));

    if (opts.o === 'linux')
        vars.branch = (opts.u ? '1.999.x' : '1.0.x');
    else  // android
        vars.branch = '0.0.x';

    vars.tag_prefix = (opts.o === 'linux' ? 'rootfs-' : '');

    vars.history_file_json = m_path.join(opts.d, m_util.format('ReleaseNotes-%s-%s.json', opts.o, vars.branch));
    vars.history_file_html = m_path.join(opts.d, m_util.format('ReleaseNotes-%s-%s.html', opts.o, vars.branch));

    debug('vars: ' + JSON.stringify(vars));

    if (!opt.argv.length)
        error('command unspecified!');

    // handle args
    for (var i = 0; i < opt.argv.length; i++)
    {
        var cmd = opt.argv[i];
        debug('cmd: ' + cmd);

        switch (cmd)
        { 
            case 'help':
                getopt.showHelp();
                process.exit(0);
            case 'gen':
                do_gen();
                break;
            case 'merge':
                do_merge();
                break;
            default:
                error(m_util.format('unknown command: %s', cmd));
        }
    }

    cleanup();

    info(m_util.format('%s successful.', vars.prog));
};

main()
