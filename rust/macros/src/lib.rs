#[macro_export]
macro_rules! hashmap {
    () => {
        ::std::collections::HashMap::new()
    };
    ($($key:literal => $val:expr),+ $(,)?) => {
        {
            let mut m = ::std::collections::HashMap::new();
            $(
                m.insert($key, $val);
            )*

            m
        }
    }
}
