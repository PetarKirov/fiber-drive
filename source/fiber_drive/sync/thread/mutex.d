///
module fiber_drive.sync.mutex;

import fiber_drive.internal.abort : enforce_zero;
import fiber_drive.sync.policy : MutexPolicy;

struct Mutex(MutexPolicy policy = MutexPolicy.init)
{
    @nogc nothrow @trusted:

    private
    {
        version (Windows)
        {
            import core.sys.windows.winbase;
            CRITICAL_SECTION hndl;
            alias HndlPtr = CRITICAL_SECTION*;
        }
        else version (Posix)
        {
            import core.sys.posix.pthread;
            pthread_mutex_t hndl;
            alias HndlPtr = pthread_mutex_t*;
        }
        else
            static assert (0, "Unsupported platform!");
    }

    ///
    @disable this();

    /// ditto
    @disable this(this);

    /// ditto
    @disable void opAssign(typeof(this) other);

    this(bool lockAfterInit) shared
    {
        init();

        if (lockAfterInit)
            lock();
    }

    ///
    void init() shared
    {
        version (Windows)
            InitializeCriticalSection(cast(HndlPtr)&hndl);

        else version (Posix)
        {
            pthread_mutexattr_t attr = void;

            pthread_mutexattr_init(&attr)
                .enforce_zero("Unable to initialize mutex!");

            pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
                .enforce_zero("Unable to initialize mutex!");

            pthread_mutex_init(cast(HndlPtr)&hndl, &attr)
                .enforce_zero("Unable to initialize mutex!");

            pthread_mutexattr_destroy(&attr)
                .enforce_zero("Unable to initialize mutex!");
        }
    }

    ///
    void deinit()
    {
        version (Windows)
            DeleteCriticalSection(cast(HndlPtr)&hndl);

        else version (Posix)
            pthread_mutex_destroy(cast(HndlPtr)&hndl)
                .enforce_zero("Unable to destroy mutex!");
    }


    ///
    void lock() shared
    {
        version (Windows)
            EnterCriticalSection(cast(HndlPtr)&hndl);

        else version (Posix)
            pthread_mutex_lock(cast(HndlPtr)&hndl)
                .enforce_zero("Unable to lock mutex!");
    }

    ///
    bool tryLock() shared
    {
        version (Windows)
            return TryEnterCriticalSection(cast(HndlPtr)&hndl) != 0;

        else version (Posix)
            return pthread_mutex_trylock(cast(HndlPtr)&hndl) == 0;
    }

    ///
    void unlock() shared
    {
        version (Windows)
            LeaveCriticalSection(cast(HndlPtr)&hndl);

        else version (Posix)
            pthread_mutex_unlock(cast(HndlPtr)&hndl)
                .enforce_zero("Unable to unlock mutex!");
    }
}

unittest
{
    auto mutex = shared Mutex!()(false);

    pragma (msg, typeof(mutex));
}
