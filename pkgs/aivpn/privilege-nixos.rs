use super::Message;
use std::path::{Path, PathBuf};

// Обёрткой и её правами управляет NixOS; GUI ничего не устанавливает от root.
fn trusted_capable_binary(path: &Path) -> bool {
    use std::os::unix::{ffi::OsStrExt, fs::MetadataExt};

    let Ok(canonical) = path.canonicalize() else {
        return false;
    };
    if !canonical.is_file()
        || !canonical.ancestors().all(|ancestor| {
            std::fs::symlink_metadata(ancestor).is_ok_and(|meta| {
                meta.uid() == 0 && meta.mode() & 0o022 == 0 && !meta.file_type().is_symlink()
            })
        })
    {
        return false;
    }
    let Ok(cpath) = std::ffi::CString::new(canonical.as_os_str().as_bytes()) else {
        return false;
    };
    let mut buf = [0u8; 64];
    let n = unsafe {
        libc::getxattr(
            cpath.as_ptr(),
            c"security.capability".as_ptr(),
            buf.as_mut_ptr().cast(),
            buf.len(),
        )
    };
    if n < 12 {
        return false;
    }
    let magic = u32::from_le_bytes(buf[0..4].try_into().unwrap());
    if magic & 0xff00_0000 == 0x0300_0000
        && n >= 24
        && u32::from_le_bytes(buf[20..24].try_into().unwrap()) != 0
    {
        return false;
    }
    let permitted = u32::from_le_bytes(buf[4..8].try_into().unwrap());
    magic & 1 != 0 && permitted & (1 << 12) != 0
}

pub(super) async fn ensure_capable_binary(
    source: &Path,
    _lang: &str,
    _sender: &mut iced::futures::channel::mpsc::Sender<Message>,
) -> Result<PathBuf, String> {
    if source == Path::new("/run/wrappers/bin/aivpn-client") && trusted_capable_binary(source) {
        Ok(source.to_owned())
    } else {
        Err("Не найдена системная обёртка AIVPN с CAP_NET_ADMIN. Примените конфигурацию NixOS.".into())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn nixos_rejects_missing_or_unprivileged_binary() {
        assert!(!trusted_capable_binary(Path::new("/nonexistent-aivpn-client")));
        assert!(!trusted_capable_binary(&std::env::current_exe().unwrap()));
    }
}
