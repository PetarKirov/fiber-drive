///
module fiber_drive.sync.policy;

struct MutexPolicy
{
    bool recursive;
    bool fair;
}
