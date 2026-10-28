"""Conversion job: where files are read from and written to, the resume journal and the log.

Two modes:
  * overlay (PC development): converted files go to <out>/<relative path>; the game data is only
    read. Later steps read a file from <out> when an earlier step already wrote it there.
  * in place (the device's first-run setup): <out> is the game data folder itself. Every file is
    written to <file>.tmp first and then renamed over the original, and each finished file is
    recorded in the journal, so a setup that is killed (battery, patcher closed) resumes where it
    stopped and never leaves a half-written file.
"""
import json, os, sys, time

STATE = '.pmunity.json'


class Job:
    def __init__(self, src, out, cfg, log=None):
        self.src = os.path.abspath(src)
        self.out = os.path.abspath(out)
        self.cfg = cfg
        self.inplace = os.path.realpath(self.src) == os.path.realpath(self.out)
        os.makedirs(self.out, exist_ok=True)
        self._log = log or (lambda m: print(m, flush=True))
        self.t0 = time.time()
        self.state_path = os.path.join(self.out, STATE)
        self.state = {'version': cfg['version'], 'done': {}, 'scaled': {}}
        if os.path.exists(self.state_path):
            with open(self.state_path) as f:
                self.state = json.load(f)
            self.state.setdefault('done', {}); self.state.setdefault('scaled', {})
            if self.state.get('pending'):
                self._finish_pending()

    @classmethod
    def reader(cls, src, cfg, log=None):
        """A job that only reads <src> (exports, checks): no journal, nothing written."""
        j = cls.__new__(cls)
        j.src = j.out = os.path.abspath(src)
        j.cfg, j.inplace, j.state_path = cfg, False, None
        j._log = log or (lambda m: print(m, flush=True))
        j.t0 = time.time()
        j.state = {'version': cfg['version'], 'done': {}, 'scaled': {}}
        return j

    def log(self, msg):
        self._log(f'[{time.time() - self.t0:7.1f}s] {msg}')

    # ---- paths
    def path_in(self, rel):
        """The newest version of a data file: the converted one if a step already wrote it."""
        p = os.path.join(self.out, rel)
        return p if os.path.exists(p) else os.path.join(self.src, rel)

    def list(self, pattern_dir, predicate):
        """Relative paths (from the source data folder) in one directory matching predicate(name)."""
        d = os.path.join(self.src, pattern_dir)
        if not os.path.isdir(d):
            return []
        return sorted(os.path.join(pattern_dir, n) if pattern_dir else n
                      for n in os.listdir(d) if predicate(n) and os.path.isfile(os.path.join(d, n)))

    # ---- writing
    def write(self, rel, data):
        """Write a converted file atomically (tmp + rename)."""
        if self.state_path is None:
            raise RuntimeError('read-only job')
        dst = os.path.join(self.out, rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        tmp = dst + '.tmp'
        with open(tmp, 'wb') as f:
            f.write(data)
            f.flush()
            if self.inplace:
                os.fsync(f.fileno())
        os.replace(tmp, dst)

    def write_file(self, rel, path):
        """Put a converted file written to <path> (on the same file system as <out>) in place, as
        write() does, without reading it into memory."""
        self.commit([(rel, path)])

    def commit(self, files):
        """Puts several converted files [(rel, written path)] in place together: the journal lists
        them first, so a job killed between two renames finishes them when it starts again (a
        serialized file and its .resS must never be half old, half new)."""
        if self.state_path is None:
            raise RuntimeError('read-only job')
        moves = []
        for rel, path in files:
            dst = os.path.join(self.out, rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            if self.inplace:
                with open(path, 'rb+') as f:
                    os.fsync(f.fileno())
            moves.append([path, dst])
        if len(moves) > 1:
            self.state['pending'] = moves
            self.save_state()
        for path, dst in moves:
            os.replace(path, dst)
        if self.state.pop('pending', None):
            self.save_state()

    def _finish_pending(self):
        for path, dst in self.state.pop('pending', None) or ():
            if os.path.exists(path):
                os.replace(path, dst)
        self.save_state()

    def work_dir(self, name):
        """An empty scratch folder for a step (<out>/.pmunity-work/<name>: a dot folder, which
        packing leaves out)."""
        import shutil
        d = os.path.join(self.out, '.pmunity-work', name)
        shutil.rmtree(d, ignore_errors=True)
        os.makedirs(d)
        return d

    # ---- journal
    def is_done(self, step, rel):
        return rel in self.state['done'].get(step, ())

    def mark_done(self, step, rel):
        self.state['done'].setdefault(step, []).append(rel)
        self.save_state()

    def save_state(self):
        if self.state_path is None:
            return
        tmp = self.state_path + '.tmp'
        with open(tmp, 'w') as f:
            json.dump(self.state, f)
        os.replace(tmp, self.state_path)

    def need_space(self, nbytes, what):
        st = os.statvfs(self.out)
        free = st.f_bavail * st.f_frsize
        if free < nbytes:
            self.log(f'ERROR: not enough free space to {what}: {free >> 20} MB free, {nbytes >> 20} MB needed')
            sys.exit(3)
