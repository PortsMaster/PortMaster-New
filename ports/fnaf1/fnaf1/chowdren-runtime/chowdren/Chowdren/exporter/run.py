import sys
import os
import shutil

class Logger(object):
    data = ''
    def __init__(self, queue):
        self.queue = queue

    def write(self, message):
        self.data += message.replace('\r\n', '\n')
        lines = self.data.split('\n')
        self.data = lines[-1]
        self.queue.put(('console', lines[:-1]))

    def flush(self):
        pass

def run_worker(input_queue, output_queue):
    sys.stdout = Logger(output_queue)
    sys.stderr = Logger(output_queue)
    from builder import Builder, StopBuild

    while True:
        args = input_queue.get()
        if args is None:
            break
        try:
            builder = Builder(*args)
            builder.run()
            output_queue.put(('result', True))
        except Exception, e:
            import traceback
            traceback.print_exc()
            print 'Error occurred, stopping build...'
            output_queue.put(('result', False))
            break

def start_worker(args):
    from multiprocessing import Queue, Process

    input_queue = Queue()
    input_queue.put(args)
    output_queue = Queue()
    process = Process(target=run_worker, args=(input_queue, output_queue))
    process.start()

    return (process, output_queue, input_queue)

def run_gui(args):
    from window import MainWindow
    from PySide import QtGui
    QtGui.QApplication.setStyle('plastique')
    app = QtGui.QApplication(sys.argv)
    window = MainWindow(*start_worker(args))
    window.show()
    sys.exit(app.exec_())

BUILD_TYPES = [
    'win',
    'winsrc',
    'src',
    'ccn'
]

def main():
    from multiprocessing import freeze_support
    freeze_support()

    build_type = BUILD_TYPES[int(sys.argv[1])]
    src = sys.argv[2]

    executable = src_dir = None
    if build_type == 'win':
        executable = sys.argv[3]
    elif build_type == 'winsrc':
        executable = sys.argv[3]
        src_dir = os.path.join(os.path.dirname(executable), 'src')
    elif build_type == 'src':
        src_dir = os.path.dirname(sys.argv[3])
    else:
        shutil.copy(src, sys.argv[3])
        return

    run_gui(('generic', src, src_dir, executable))

if __name__ == '__main__':
    main()