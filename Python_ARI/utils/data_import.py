import mne
from functools import reduce
import numpy as np

def data_import(input_dir, p_id, cond):
    '''
    Load data

    Parameters
    ----------
    input_dir: directory where data is found
    p_id : participant ID
    cond: condition
    '''
    # define epoch name
    #input_fname =  f"{input_dir}/sub-{p_id}/eeg/epochs_{p_id}_{cond}.fif"
    #raw_data = mne.read_epochs(input_fname)

    input_fname =  f"{input_dir}/{p_id}_{cond}_5min.set"
    raw_data = mne.io.read_raw_eeglab(input_fname)

    # remove channels marked as bad and non-brain channels
    raw_data.drop_channels(raw_data.info['bads'])
    raw_data.load_data()

    return raw_data


def filter_channels(data1, data2, data3 = False):
    sfreq = 250

    if data3:
        intersect = reduce(np.intersect1d, (data1.info['ch_names'], data2.info['ch_names'], data3.info['ch_names']))
    else:
        intersect = reduce(np.intersect1d, (data1.info['ch_names'], data2.info['ch_names']))

    drop_1 = set(data1.info['ch_names']) ^ set(intersect)
    drop_2 = set(data2.info['ch_names']) ^ set(intersect)
    if bool(data3):
        drop_3 = set(data3.info['ch_names']) ^ set(intersect)

    data1.drop_channels(drop_1)
    data1.resample(sfreq=sfreq)
    data1 = np.array(data1._data)

    data2.drop_channels(drop_2)
    data2.resample(sfreq=sfreq)
    data2 = np.array(data2._data)

    if bool(data3):
        data3.drop_channels(drop_3)
        data3.resample(sfreq=sfreq)
        data3 = np.array(data3._data)
        return data1, data2, data3, sfreq

    else:
        return data1, data2, sfreq
